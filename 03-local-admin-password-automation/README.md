# Automated Local Admin Password Lifecycle

## Executive Summary
Development and deployment of an automated lifecycle and periodic rotation mechanism for local administrator passwords across more than 5,000 corporate workstations using Microsoft Endpoint Configuration Manager (MECM / SCCM). The solution eliminates static credentials, standardizes security baselines, and mitigates lateral movement risks in enterprise environments.

---

## Technical Architecture & MECM Workflow

```mermaid
graph TD
    subgraph MECM Central Management
        CI[Configuration Item / Discovery & Remediation Scripts] -->|Baseline Deployment| CB[Configuration Baseline Collection]
    end

    subgraph Endpoint Execution (5000+ Workstations)
        CB -->|Periodic Evaluation| Discovery[Discovery Script: Validate Credentials & Log Event]
        Discovery -->|NonCompliant Status Trigger| Remediation[Remediation Script: ADSI Password Update & Commit]
        Remediation -->|Post-Change Validation| EventLog[Windows Event Viewer: Local Audit Logs]
    end
```
