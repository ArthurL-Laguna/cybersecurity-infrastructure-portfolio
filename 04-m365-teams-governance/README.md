# Automated Microsoft Teams Governance & Policy Enforcement

## Overview
* **Core Domains:** Cybersecurity, M365 Governance, PowerShell Automation, Identity & Access Management (Teams Admin).
* **Project Focus:** Design and implementation of a scalable digital governance model and automated PowerShell batch assignment framework to enforce strict communication, meeting, and application security policies for thousands of students across educational institutions.

---

## Architecture & Compliance Workflow

```mermaid
graph TD
    subgraph M365 Central Admin
        CSV[Student Data Source / UPN List] -->|Script Ingestion| Filter[Filter Pipeline: Get-CsOnlineUser]
    end

    subgraph Automated Policy Enforcement Engine
        Filter -->|Check State & Apply| CP[Calling Policy: Restrict PSTN & Voicemail]
        Filter -->|Check State & Apply| ASP[App Setup Policy: Block User Pinning]
        Filter -->|Check State & Apply| MP[Messaging Policy: Strict Giphy & Chat Control]
        Filter -->|Check State & Apply| MEP[Meeting Policy: Disable Private Meetings & Cloud Recording]
    end

    subgraph Resiliency Layer
        MEP -->|Session Timeout Check| Session[Proactive PSSession Reset & Reconnect]
        Session -->|Audit Logging| Log[Execution Timestamp & Log File]
    end
```
