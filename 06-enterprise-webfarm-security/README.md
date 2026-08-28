# 06-Enterprise WebFarm Edge Security & SSL Offloading

## Executive Summary
Design and implementation of a high-availability, secure enterprise web farm infrastructure focused on perimeter defense, TLS/SSL offloading, L4/L7 load balancing, and backend isolation using Microsoft Internet Information Services (IIS) and Application Request Routing (ARR). The architecture mitigates volumetric DoS vectors, eliminates single points of failure (SPOF), and enforces modern cryptographic standards without exposing internal application servers directly to the public internet.

---

## Technical Architecture

```mermaid
graph TD
    Client[Internet / External Clients] -->|HTTPS / TLS 1.2+ Only| ARR[Edge Reverse Proxy / ARR Load Balancer]
    
    subgraph Edge Security & SSL Offloading
        ARR -->|SSL Offloading / Health Probes| LB Logic{L4/L7 Traffic Distribution}
    end

    subgraph Internal Isolated Web Farm
        LB Logic -->|HTTP / Weighted Round Robin| Web1[IIS Farm Node 01]
        LB Logic -->|HTTP / Weighted Round Robin| Web2[IIS Farm Node 02]
    end

    subgraph Centralized Governance
        Web1 -.->|Read-Only Shared Config| Store[IIS Shared Configuration Repository]
        Web2 -.->|Read-Only Shared Config| Store
    end
```
## Server Specifications & Inventory

* **Load Balancer & Edge Proxy (`LB-Node-01`):** Reverse proxy, SSL termination, and ARR load balancer[cite: 6] with 4 vCPUs, 8 GB RAM, and local disks for OS and configuration repository.
* **Web Farm Node 01 (`FARM-Node-01`):** Primary backend application server[cite: 6] with 16 vCPUs, 8 GB RAM, and dedicated storage for application data and replication.
* **Web Farm Node 02 (`FARM-Node-02`):** Secondary backend application server[cite: 6] mirroring `FARM-Node-01` to provide redundancy and continuous high availability.

---

## Repository Contents (Sanitized)
* `docs/`: Architecture diagrams and technical specification files.
* `src/setup-arr-farm.ps1`: Automated PowerShell deployment script for configuring the ARR server farm.
* `src/configure-replication.ps1`: Synchronization and file replication setup scripts.
* `src/enable-shared-config.ps1`: Automation scripts for setting up centralized IIS shared configuration.

---

*Disclaimer: All IP addresses, server names, credentials, and domain identifiers in this repository have been fully sanitized and anonymized[cite: 6].*
