# DaishoSentinel: AI-Driven SOC Blue Team Node

**DaishoSentinel** is a modular Blue Team control node designed for segmented, Zero Trust cybersecurity simulation environments. 
It powers defensive operations within the **Daisho Platform**, orchestrating multi-VLAN routing, traffic inspection, AI-enhanced detection, and configuration hardening.

## Purpose

- Serve as central Blue Team node (host: `Shihan`)
- Route and control traffic between segmented VLANs
- Enable intrusion detection and packet analysis (Suricata, Zeek)
- Provide scripts for system backup and automation
- Simulate real-world pivoting, lateral movement, and defense scenarios

## Architecture

- Host OS: Linux Mint 22 MATE
- Hardware: Intel i5, 8GB RAM
- Roles:
  - Multi-VLAN Router (VLANs 10, 20, 30)
  - Central Firewall / IDS
  - Monitoring & Logging Hub

## Directory Overview

| Folder        | Purpose                                      |
|---------------|----------------------------------------------|
| `docs/`       | All technical documentation                  |
| `scripts/`    | Shell scripts for setup and automation       |
| `configs/`    | Sample config files (firewall, network, etc.)|
| `assets/`     | Diagrams, screenshots                        |

## VLAN Configuration

| VLAN | Description  | Subnet           |
|------|--------------|------------------|
| 10   | Blue Zone    | 192.168.10.0/24  |
| 20   | Red Zone     | 192.168.20.0/24  |
| 30   | AI & Admin   | 192.168.30.0/24  |

## Status

Phase 1: Base system configuration & backup strategy complete  
Phase 2: VLAN setup and routing in progress

## License

MIT License
