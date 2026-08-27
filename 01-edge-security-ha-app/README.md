# Edge Security & High Availability Architecture for Critical Applications

## Executive Summary
Design and implementation of a high-availability, secure edge architecture for a mission-critical educational application (App Movvy). The solution was engineered to withstand massive concurrent traffic spikes during school hours while ensuring zero downtime, continuous file replication, and complete perimeter protection for sensitive student data.

> **Public Recognition:** The platform's resilience and positive impact on community safety were highlighted in regional media outlets.

---

## Technical Architecture

```mermaid
graph TD
    Client[Internet / Mobile Clients] -->|HTTPS / TLS 1.2+| ARR[Reverse Proxy / ARR Load Balancer]
    
    subgraph Web Farm Zone
        ARR -->|Weighted Round Robin| Web1[IIS Web Node 01]
        ARR -->|Weighted Round Robin| Web2[IIS Web Node 02]
        Web1 <-->|DFS-R Full Mesh| Web2
    end

    subgraph Data & Session Layer
        Web1 -->|Session Offload| Redis[Redis Cache Cluster]
        Web2 -->|Session Offload| Redis
        Web1 -->|Audited ODBC| SQL[(SQL Server Cluster)]
        Web2 -->|Audited ODBC| SQL
    end
