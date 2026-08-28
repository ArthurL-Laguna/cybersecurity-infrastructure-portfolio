# 06-Enterprise WebFarm Security & High Availability

## Executive Summary
Design and implementation of a high-availability, secure enterprise web farm infrastructure using Microsoft Internet Information Services (IIS) and Application Request Routing (ARR)[cite: 6]. The architecture provides perimeter security, load balancing, centralized configuration management, and continuous file synchronization to guarantee high performance and data integrity[cite: 6].

---

## Technical Architecture

```mermaid
graph TD
    Client[Internet / External Clients] -->|HTTPS / TLS 1.2+| ARR[Reverse Proxy / ARR Load Balancer / LB-Node-01]
    
    subgraph Web Farm Zone
        ARR -->|Weighted Round Robin / ARRAffinity| Web1[IIS Farm Node 01 / FARM-Node-01]
        ARR -->|Weighted Round Robin / ARRAffinity| Web2[IIS Farm Node 02 / FARM-Node-02]
        Web1 <-->|File Replication / D:\Dados| Web2
    end

    subgraph Config & Storage Layer
        Web1 -.->|SMB Shared Configuration| ARR
        Web2 -.->|SMB Shared Configuration| ARR
    end
```
