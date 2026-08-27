# Automated Local Admin Password Lifecycle

## Executive Summary
Development and deployment of an automated lifecycle and periodic rotation mechanism for local administrator passwords across more than 5,000 corporate workstations using Microsoft Endpoint Configuration Manager (MECM / SCCM). The solution eliminates static credentials, standardizes security baselines, and mitigates lateral movement risks in enterprise environments.

---

## Technical Architecture & MECM Workflow

```mermaid
graph TD
    subgraph SCCM Central Management
        CI[Configuration Item / Discovery & Remediation] -->|Baseline Deployment| CB[Configuration Baseline Collection]
    end

    subgraph Endpoint Execution (5000+ Workstations)
        CB -->|Periodic Evaluation| Discovery[Discovery Script: Validate Credentials & Log Event]
        Discovery -->|NonCompliant Status Trigger| Remediation[Remediation Script: ADSI Password Update & Commit]
        Remediation -->|Post-Change Validation| EventLog[Windows Event Viewer: Local Audit Logs]
    end
```
---

## Cenário & Solução Técnica
* **O Problema:** A rede contava com mais de 5.000 estações de trabalho onde a conta de administrador local representava um vetor crítico de risco, permitindo o uso de credenciais padronizadas e facilitando o movimento lateral (*lateral movement*) em caso de invasão[cite: 1].
* **Discovery Script:** Desenvolvido em PowerShell e integrado ao Configuration Item (CI) do SCCM para validar localmente as credenciais administrativas utilizando a API `System.DirectoryServices.AccountManagement`, registrando eventos de auditoria no Event Viewer[cite: 1].
* **Remediation Script:** Acionado automaticamente em caso de falha de conformidade (`NonCompliant`), executando rotinas em PowerShell/ADSI para alterar a senha da conta de forma silenciosa e segura, seguida de validação e registro de logs de sucesso[cite: 1].
* **Configuration Baseline:** Os itens de configuração foram agrupados em uma Baseline direcionada às coleções de estações, permitindo monitoramento centralizado em tempo real de status `Compliant`, `Non-Compliant` e erros operacionais[cite: 1].

---

## Repository Contents (Sanitized)
* `docs/`: Documentação técnica oficial e procedimentos operacionais padrão (SIT).
* `src/Invoke-LocalAdminDiscovery.ps1`: Script de descoberta do SCCM para validação de credenciais e registro de eventos.
* `src/Invoke-LocalAdminRemediation.ps1`: Script de remediação automatizada via ADSI para atualização de senha.
* `src/Audit-LocalAdminEvents.ps1`: Ferramenta de auditoria e leitura dos logs locais do Event Viewer.

---

*Disclaimer: All IP addresses, server names, credentials, domain identifiers, and proprietary names in this repository have been fully sanitized and anonymized.*
