# 001 – Routing Mode: Host vs Docker Container

**Date:** 2025-07-01  
**Component:** Shihan (Blue Team Node)  
**Decision:** Route directly on the host system instead of using Docker container.

## Context
The need to route between VLANs 10, 20, and 30 requires a central routing mechanism.

## Options Considered
- Native host-based routing using VLAN subinterfaces.
- Docker container with privileged networking and `macvlan`.

## Chosen Approach
Use **host-based routing** on Shihan for:
- Simplicity in configuration and management.
- Full access to network interfaces and traffic visibility.
- Seamless integration with IDS tools (Suricata, Zeek).
- Resource efficiency on limited hardware.

## Status
✅ Implemented
