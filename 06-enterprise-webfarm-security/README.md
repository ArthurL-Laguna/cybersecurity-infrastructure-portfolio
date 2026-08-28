# 06-Enterprise WebFarm Security & High Availability

## Project Overview

This repository contains the technical documentation, architecture specifications, and implementation guidelines for a high-availability, secure enterprise web farm deployment. Based on a production-grade infrastructure model, this case study demonstrates best practices in edge security, TLS traffic encryption, centralized configuration management, and load balancing using Microsoft Internet Information Services (IIS) and Application Request Routing (ARR).

---

## Architecture Topology

The infrastructure is built on a 3-tier high-availability architecture utilizing Windows Server and IIS, deployed across virtualized environments.

```text
                  [ Internet ]
                       │
                       ▼
         [https://app.domain.tld/Status](https://app.domain.tld/Status)
                       │
                       ▼
          [ Edge Firewall / Routing ]
                       │
                       ▼
         [ Load Balancer & Edge Proxy ]
               (LB-Node-01)
               IP: [LoadBalancer-IP]
                       │
         ┌─────────────┴─────────────┐
         ▼                           ▼
[ IIS Farm Node 01 ]        [ IIS Farm Node 02 ]
    (FARM-Node-01)              (FARM-Node-02)
   IP: [Node01-IP]             IP: [Node02-IP]
         │                           │
         └─────────────┬─────────────┘
                       ▼
             [ File Replication ]
             (Synchronized Storage)
