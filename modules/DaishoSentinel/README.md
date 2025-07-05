# DaishoSentinel: AI-Driven SOC Blue Team Node

**DaishoSentinel** is a modular Blue Team control node designed for segmented, Zero Trust cybersecurity simulation environments.
It supports defensive operations within the **Daisho Platform**, orchestrating multi-VLAN routing, traffic inspection, AI-enhanced detection, and configuration hardening.

## Purpose

* Serve as central Blue Team node (host: `<NODE_A>`)
* Route and control traffic between segmented VLANs
* Enable intrusion detection and packet analysis (e.g., Suricata, Zeek)
* Provide scripts for system backup and automation
* Simulate real-world pivoting, lateral movement, and defense scenarios

## Architecture

* Host OS: Linux (distro-neutral)
* Hardware: Mid-range x86\_64 CPU, 8GB RAM
* Roles:
  * Multi-VLAN Router (e.g., VLANs 10, 20, 30)
  * Central Firewall / IDS
  * Monitoring & Logging Hub

## Directory Overview

| Folder     | Purpose                                       |
| ---------- | --------------------------------------------- |
| `assets/`  | Diagrams, screenshots                         |
| `configs/` | Sample config files (firewall, network, etc.) |
| `docs/`    | All technical documentation                   |
| `modules/` | Platform modules                              |

## VLAN Configuration

| VLAN | Description | Subnet (Example) |
| ---- | ----------- | ---------------- |
| 10   | Blue Zone   | 10.0.10.0/24     |
| 20   | Red Zone    | 10.0.20.0/24     |
| 30   | AI & Admin  | 10.0.30.0/24     |

## Status

Phase 1: Base system configuration & backup strategy complete
Phase 2: VLAN setup and routing in progress

## License

MIT License

