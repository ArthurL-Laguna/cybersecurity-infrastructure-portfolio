
# Enterprise WebFarm Security & High Availability

## Project Overview

This repository contains the technical documentation, architecture specifications, and implementation guidelines for a high-availability, secure enterprise web farm deployment. This infrastructure model demonstrates best practices in edge security, TLS traffic encryption, centralized configuration management, and load balancing using Microsoft Internet Information Services (IIS) and Application Request Routing (ARR).

---

## Architecture Topology

The infrastructure is built on a 3-tier high-availability architecture utilizing Windows Server and IIS, deployed across virtualized environments.


## Server Specifications & Inventory

### 1. Load Balancer & Edge Proxy Node
* **Hostname:** `LB-Node-01`
* **Role:** Reverse Proxy, SSL Termination Gateway, and Application Request Routing (ARR) Load Balancer
* **IP Address:** `[LoadBalancer-IP]`
* **Operating System:** Microsoft Windows Server (64-bit)
* **Hardware Specs:** 4 vCPUs, 8 GB RAM, Paravirtual SCSI, VMXNET3 Ethernet
* **Storage:** Local Disk C: (OS), Local Disk D: (Shared Config Repository)

### 2. Web Farm Node 01
* **Hostname:** `FARM-Node-01`
* **Role:** Backend Application Server / Primary Replication Member
* **IP Address:** `[Node01-IP]`
* **Operating System:** Microsoft Windows Server (64-bit)
* **Hardware Specs:** 16 vCPUs, 8 GB RAM, Paravirtual SCSI, VMXNET3 Ethernet
* **Storage:** Local Disk C: (OS), Local Disk D: (Application Data & Storage Replica)

### 3. Web Farm Node 02
* **Hostname:** `FARM-Node-02`
* **Role:** Backend Application Server / Secondary Replication Member
* **IP Address:** `[Node02-IP]`
* **Operating System:** Microsoft Windows Server (64-bit)
* **Hardware Specs:** 16 vCPUs, 8 GB RAM, Paravirtual SCSI, VMXNET3 Ethernet
* **Storage:** Local Disk C: (OS), Local Disk D: (Application Data & Storage Replica)

---

## Core Security & High Availability Mechanisms

### Edge Security & ARR Load Balancing
* **Application Request Routing (ARR):** Acts as the reverse proxy gateway, distributing incoming traffic using weighted round-robin distribution.
* **Client Affinity:** Enabled via cookie-based persistence (`ARRAffinity`) to ensure session state continuity across backend nodes.
* **Proxy Configuration:** Configured to preserve client source IPs using standard headers (`X-Forwarded-For`), include TCP ports from client IPs, and append tracking GUIDs (`X-ARR-LOG-ID`).
* **SSL Offloading / Pass-Through:** Configured to maintain secure end-to-end transport integrity across proxy boundaries.

### Centralized Configuration Management
* **IIS Shared Configuration:** Both backend nodes point their configuration repository to an SMB share (`\\LB-Node-01\IIS$\Shared Configuration`) hosted on the load balancer.
* **Synchronized Settings:** Configuration files (`applicationHost.config`, `administration.config`, and `configEncKey.key`) are centrally managed, guaranteeing zero configuration drift across farm nodes.

### File Synchronization
* **Replication Architecture:** A continuous replication mechanism synchronizes the application content directory between the primary and secondary backend nodes.
* **Data Integrity:** Guarantees absolute binary parity for all application assets, dynamic uploads, and web scripts across all backend farm members in real-time.

---

## Repository Structure

```text
enterprise-webfarm-security/
├── README.md
├── docs/
│   ├── architecture-diagram.png
│   └── technical-specifications.md
├── scripts/
│   ├── setup-arr-farm.ps1
│   ├── configure-replication.ps1
│   └── enable-shared-config.ps1
└── configs/
    ├── applicationHost.template.config
    └── web.routing.rules.xml
