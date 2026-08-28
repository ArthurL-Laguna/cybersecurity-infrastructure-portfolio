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
