# Active Directory Session Governance & UserLock Automation

## Executive Summary
Implementation of an automated session management and user experience workaround framework using Active Directory Group Policy Objects (GPOs), native Task Scheduler, and PowerShell. The solution mitigates the rigid limitations of third-party access control tools (UserLock), which enforce abrupt session lockouts without prior notice. By deploying a dynamic logon script and an interactive WPF notification module, this framework prevents unsaved data loss and eliminates unnecessary service desk tickets.

---

## Architecture & Workaround Workflow

```mermaid
graph TD
    subgraph Active Directory & GPO
        GPO[User Configuration GPO / Logon Script] -->|Execution on Startup| Script[Logon Script: Register-ScheduledTask.ps1]
        Script -->|Query Group Membership| AD[Active Directory Security Groups]
    end

    subgraph Client Endpoint Execution
        AD -->|Identify Shift & Timing| Task[Task Scheduler: Register 'Notificacao de Bloqueio']
        Task -->|Trigger Visual Countdown| UI[PowerShell Windows Forms / WPF: 15-Min Timer Warning]
        UI -->|User Action / Save Data| Safe[Data Saved / Graceful Logoff]
    end
```
