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

* **Load Balancer & Edge Proxy (`LB-Node-01`):** Reverse proxy, SSL/TLS termination point, and ARR load balancer equipped with 4 vCPUs, 8 GB RAM, and local storage for OS and edge configuration.
* **Web Farm Node 01 (`FARM-Node-01`):** Primary backend application server operating in an isolated network segment, equipped with 16 vCPUs and 8 GB RAM.
* **Web Farm Node 02 (`FARM-Node-02`):** Secondary backend application server operating in parallel to guarantee high availability and redundant traffic processing.

---

## Key Engineering Decisions & Hardening

* **Perimeter Security & Backend Isolation:** Configured IIS ARR 3.0 as a single point of entry to hide internal topology and IP addresses of backend application nodes, drastically reducing direct attack surfaces.
* **Cryptographic Offloading & TLS Hardening:** Centralized SSL/TLS processing at the edge layer to optimize backend CPU performance. Enforced TLS 1.2/1.3 and disabled legacy ciphers (SSLv3, TLS 1.0, 3DES) to protect against eavesdropping and protocol downgrade attacks.
* **Health Probes & DoS Mitigation:** Implemented Layer 7 health monitoring probes to detect node degradation in real time, triggering automatic failover. Enforced connection timeouts and buffer threshold limits to contain malicious or incomplete requests.
* **Session Integrity:** Applied secure cookie-based session stickiness (`ARRAffinity`) to maintain navigation state consistency while preventing session hijacking risks.

---

## Repository Contents (Sanitized)
* `docs/`: Network flow blueprints, threat models, and architectural specifications.
* `src/setup-arr-farm.ps1`: Automated PowerShell deployment script for configuring the ARR reverse proxy server farm.
* `src/configure-ssl-offloading.ps1`: Automation script for centralizing certificates, SSL offloading, and HTTP/HTTPS redirect rules.
* `src/hardening-tls-ciphers.ps1`: Script for disabling deprecated SCHANNEL protocols and enforcing strong TLS 1.2/1.3 cipher suites.

---

*Disclaimer: All IP addresses, server names, credentials, and domain identifiers in this repository have been fully sanitized and anonymized.*
