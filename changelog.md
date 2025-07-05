# Changelog: Daisho Platform

All notable changes to this project and subprojects will be documented in this file.

This file documents the evolution of components and subprojects within the **Daisho Platform**, a modular cybersecurity architecture combining AI, DevSecOps, Blue/Red Team operations, and Zero Trust segmentation.


## [v0.2.2] - 2025-07-05

### Changed
- All documentation, scripts and modules containing sensitive information were anonymized

## [v0.2.0] - 2025-07-03

### Changed
- Restructured the entire repository to follow a modular and scalable format.
- Introduced `/modules/` folder containing each Daisho component:
  - `DaishoSentinel`, `DaishoRedMindOps`, `DaishoForge`, `DaishoCore`
- Added standard internal structure to each module: `scripts/`, `configs/`, `docs/`, `assets/`
- Moved technical decisions to `/decisions/` as formal Architecture Decision Records (ADRs).
- Created unified documentation folder `/docs/` and assets folder `/assets/`.

### Added
- README.md template for modules
- Standard roles and directory overview for each module

## [v0.1.0] - 2025-07-01

### Added
- Initial project structure created:
  - `/modules/DaishoCore/` for Central AI brain, APIs, control flow and orchestration - (Core Logic & AI Agents)
  - `/modules/DaishoForge/` for Pipelines, infrastructure-as-code, CI/CD & containerization - (DevSecOps Builder)
  - `/modules/DaishoFramework/` for Open, customizable version for community and enterprise use - (Open Source Modular Framework)
  - `/modules/DaishoRedMindOps/` for AI-assisted offensive tools, C2 simulation, and automation - (Red Team Framework)
  - `/modules/DaishoSentinel/` for Multi-VLAN router, IDS/IPS, firewall, and AI monitoring hub - (Blue Team Node)
  - .gitignore
  - changelog.md
  - CONTRIBUTING.md
  - LICENCE
  - Readme.md
  - SECURITY.md

---

# Changelog: DaishoSentinel

* **DaishoSentinel** is the defensive and control node within the modular ecosystem of the **Daisho Platform**. 
* It operates as the Blue Team control hub, Multi-VLAN router, and detection core in the segmented SOC Home Lab.

This changelog part focuses on the **DaishoSentinel** subproject: the Blue Team control node responsible for routing, detection, and centralized monitoring in the segmented SOC Home Lab environment.

This changelog tracks functional and architectural milestones specific to the configuration, automation, and evolution of this node.

## [v0.1.0] - 2025-07-01

### Added
- Initial repository structure created:
  - `docs/` for technical documentation
  - `configs/` for system and network configurations
  - `scripts/` for automation and backup tasks
  - `assets/` for diagrams and screenshots
- English `README.md` created with clear description of purpose, architecture, and VLAN design.
- Documented network segmentation of the SOC Home Lab:
  - VLAN 10: Blue Zone (MODE_A, NODE_B)
  - VLAN 20: Red Zone (NODE_C)
  - VLAN 30: Experimental/AI Zone (NODE_D)
- Created automated **incremental backup script** (`node_backup.sh`) with log tracking.
- Defined **dual-destination backup strategy** for resilience:
  - Primary: Remote network share on Dojo (`/mnt/dojo_snapshots`)
  - Secondary: USB external drive (`/media/<user>/usb_backup`)
- Logging system for backup status created (`.node_backup_YYYYMMDD_HHMMSS.log`).
- Snapshot strategy defined: **single latest version only** to preserve storage space.

---

## [Unreleased]

### Planned
- Networking topology diagram added under `docs/networking/`.
- Recorded decision log: router role will run directly on host (Shihan) instead of containerized (Docker), based on simplicity, traffic visibility, and system control.
- Add VLAN interface configuration for routing between VLAN 10, 20, and 30.
- Enable IP forwarding and persist routing behavior.
- Add base firewall rules using `iptables` or `nftables`.
- Integrate Suricata or Zeek for traffic analysis and IDS functionality.
- Document system hardening steps (SSH, sudoers, sysctl).
- Create automated restoration script using backup.
- Implement AI-based anomaly detection proof-of-concept in the Blue Team node.
