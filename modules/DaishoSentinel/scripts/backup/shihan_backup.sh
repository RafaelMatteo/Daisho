#!/bin/bash

set -e  # Detener ejecución en errores inesperados

# ==== CONFIGURACIÓN ====

FECHA=$(date +"%Y%m%d_%H%M%S")
LOG="/home/rafael/logs/shihan_backup_$FECHA.log"
EXCLUDE="/home/rafael/.shihan_backup.exclude"

# Respaldo Samba
MOUNT_POINT="/mnt/dojo_snapshots"
DESTINO="$MOUNT_POINT/shihan_backup"
SAMBA_SOURCE="//192.168.10.51/Snapshots"
CREDENTIALS="/home/rafael/.smbcredentials"

# Respaldo USB
USB_MOUNT="/media/rafael/respaldos_usb"
USB_DEST="$USB_MOUNT/shihan_backup"

# Crear carpeta de logs si no existe
mkdir -p /home/rafael/logs

# ==== MONTAJE SAMBA ====

echo "🔌 Montando recurso Dojo..."

if ! mountpoint -q "$MOUNT_POINT"; then
    sudo mount -t cifs "$SAMBA_SOURCE" "$MOUNT_POINT" \
        -o credentials="$CREDENTIALS",vers=3.0,uid=$(id -u),gid=$(id -g)
    if [ $? -ne 0 ]; then
        echo "❌ Error: no se pudo montar el recurso Samba." | tee -a "$LOG"
        notify-send "Respaldo Shihan" "❌ Error al montar el recurso Samba."
        exit 1
    fi
else
    echo "✅ Recurso ya montado."
fi

# ==== VERIFICACIÓN DE ACCESO SAMBA ====

if [ ! -d "$DESTINO" ]; then
    echo "📂 Creando carpeta destino $DESTINO"
    mkdir "$DESTINO" || {
        echo "❌ No se pudo crear $DESTINO. Verificá permisos." | tee -a "$LOG"
        notify-send "Respaldo Shihan" "❌ Error al crear carpeta destino."
        sudo umount "$MOUNT_POINT"
        sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
        exit 1
    }
fi

if [ ! -w "$DESTINO" ]; then
    echo "❌ No tenés permisos de escritura en $DESTINO" | tee -a "$LOG"
    notify-send "Respaldo Shihan" "❌ Sin permisos de escritura en destino."
    sudo umount "$MOUNT_POINT"
    sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
    exit 1
fi

# ==== RSYNC A DOJO ====

echo "🔄 Iniciando copia incremental hacia Dojo..." | tee -a "$LOG"

rsync -aAXv --delete \
    --exclude-from="$EXCLUDE" \
    /home/rafael /etc /opt /usr/local /var/log "$DESTINO" 2>>"$LOG" | tee -a "$LOG"

RSYNC_CODE=${PIPESTATUS[0]}

# ==== DESMONTAJE DE DOJO ====

echo "🔌 Desmontando recurso Dojo..."
sudo umount "$MOUNT_POINT"

# ==== COPIA A DISCO USB ====

echo "💽 Verificando USB para segunda copia..." | tee -a "$LOG"

# Verificar si el punto de montaje existe
if [ ! -d "$USB_MOUNT" ]; then
    echo "📁 Creando punto de montaje $USB_MOUNT..." | tee -a "$LOG"
    sudo mkdir -p "$USB_MOUNT"
fi

# Si no está montado, intentar montarlo manualmente
if ! mountpoint -q "$USB_MOUNT"; then
    echo "🔌 USB no montado. Intentando montar /dev/sdb1 en $USB_MOUNT..." | tee -a "$LOG"
    if ! sudo mount -t ext4 /dev/sdb1 "$USB_MOUNT"; then
        echo "❌ Error al montar /dev/sdb1. Se omite la copia a USB." | tee -a "$LOG"
        notify-send "Backup USB" "❌ Falló el montaje del USB. Copia omitida."
        USB_AVAILABLE=false
    else
        echo "✅ USB montado correctamente en $USB_MOUNT." | tee -a "$LOG"
        USB_AVAILABLE=true
    fi
else
    echo "✅ USB ya montado en $USB_MOUNT." | tee -a "$LOG"
    USB_AVAILABLE=true
fi

# Si el USB está disponible, hacer la copia
if [ "$USB_AVAILABLE" = true ]; then
    echo "📂 Iniciando copia a USB ($USB_DEST)..." | tee -a "$LOG"
    mkdir -p "$USB_DEST"

    rsync -aAXv --delete \
        --exclude-from="$EXCLUDE" \
        /home/rafael /etc /opt /usr/local /var/log "$USB_DEST" 2>>"$LOG" | tee -a "$LOG"

    echo "✅ Copia a USB completada exitosamente." | tee -a "$LOG"
    notify-send "Backup USB" "✅ Segunda copia realizada correctamente."
fi


# ==== INFORME DE ERRORES (si los hubo) ====

if [ "$RSYNC_CODE" -eq 0 ]; then
    echo "✅ Sincronización completa: Shihan → Dojo ($DESTINO)" | tee -a "$LOG"
    notify-send "Respaldo Finalizado" "✅ Backup en Dojo completado sin errores."

elif [ "$RSYNC_CODE" -eq 23 ]; then
    echo "⚠️  Sincronización con advertencias: Algunos archivos fueron omitidos por permisos." | tee -a "$LOG"

    echo "" >> "$LOG"
    echo "📊 Resumen de archivos no respaldados por falta de permisos:" >> "$LOG"
    echo "-----------------------------------------------------------" >> "$LOG"

    grep -E "Permission denied|failed to open|failed to stat|failed to read|opendir.*failed" "$LOG" | \
    awk -F'rsync: \\[sender\\] ' '{print $2}' | \
    awk -F'[:]' '{printf "• %-60s ❌ %s\n", $1, $2}' >> "$LOG"

    TOTAL_FALLAS=$(grep -cE "Permission denied|failed to open|failed to stat|failed to read|opendir.*failed" "$LOG")

    echo "-----------------------------------------------------------" >> "$LOG"
    echo "🔸 Total de archivos/directorios omitidos: $TOTAL_FALLAS" >> "$LOG"

    notify-send "Respaldo Shihan Finalizado" "⚠️ Omitidos $TOTAL_FALLAS archivos por permisos."

else
    echo "❌ Error crítico en rsync (Código $RSYNC_CODE)" | tee -a "$LOG"
    notify-send "Respaldo Shihan" "❌ Error en rsync: código $RSYNC_CODE. Ver log."
    exit 1
fi

# ==== LIMPIEZA ====

sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'

