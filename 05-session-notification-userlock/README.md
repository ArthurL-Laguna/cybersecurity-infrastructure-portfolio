
# Active Directory Session Governance & UserLock Automation

## Executive Summary
Implementation of an automated session management and user experience workaround framework using Active Directory Group Policy Objects (GPOs), native Task Scheduler, and PowerShell. The solution mitigates the rigid limitations of third-party access control tools (UserLock), preventing data loss from abrupt session lockouts and eliminating unnecessary service desk tickets.

---

## Architecture & Workaround Workflow

```mermaid
graph TD
    subgraph Active Directory & GPO
        GPO[User Configuration GPO / Logon Script] -->|Execution on Startup| Script[Logon Script: ScriptGPO.ps1]
        Script -->|Query Group Membership| AD[Active Directory Security Groups]
    end

    subgraph Client Endpoint Execution
        AD -->|Identify Shift Timing| Task[Task Scheduler: Register Countdown Task]
        Task -->|Trigger Visual Countdown| UI[WPF / Windows Forms: 15-Min Timer Warning]
        UI -->|User Action / Save Data| Safe[Data Saved / Graceful Logoff]
    end
```
