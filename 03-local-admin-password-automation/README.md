# Automated Local Administrator Password Lifecycle

## Overview
* **Core Domains:** Cybersecurity, IT Infrastructure, Identity and Access Management (IAM), Compliance Automation & Endpoint Hardening.
* **Project Focus:** Development and deployment of an automated lifecycle and periodic rotation mechanism for local administrator passwords across more than 5,000 corporate workstations, eliminating static credential risks and reused passwords.

---

## Architecture & Compliance Workflow

```mermaid
graph TD
    subgraph SCCM Central Management
        CI[Configuration Item / Discovery & Remediation] -->|Baseline Deployment| CB[Configuration Baseline Collection]
    end

    subgraph Endpoint Execution ["5000+ Workstations"]
        CB -->|Periodic Evaluation| Discovery[Discovery Script: Validate Credentials & Log Event]
        Discovery -->|NonCompliant Status Trigger| Remediation[Remediation Script: ADSI Password Update & Commit]
        Remediation -->|Post-Change Validation| EventLog[Windows Event Viewer: Local Audit Logs]
    end
```
