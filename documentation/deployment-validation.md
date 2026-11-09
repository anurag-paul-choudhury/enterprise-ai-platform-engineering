# Azure Infrastructure Deployment and Validation Record

**Project:** Enterprise AI Platform Engineering on Azure  
**Deployment:** `enterprise-ai-platform-foundation`  
**Date:** 9 November 2026  
**Deployment mode:** Incremental  
**Resource group:** `rg-enterprise-ai-platform`  
**Region:** Central India  
**Result:** Succeeded

## 1. Deployment Overview

The modular Bicep infrastructure was deployed successfully using Azure CLI.

The main deployment template, `infrastructure/main.bicep`, orchestrates eight modules:

- Network
- Identity
- Security
- Key Vault
- Storage
- Network associations
- Key Vault RBAC
- Storage RBAC

Explicit module dependencies ensure that network associations and role assignments are deployed after their required resources.

## 2. Deployment Validation

The deployment completed with provisioning state `Succeeded` in approximately 30 seconds.

Post-deployment checks confirmed:

### Network

- Virtual network address space: `10.0.0.0/16`
- Application subnet: `10.0.1.0/24`
- Private endpoint subnet: `10.0.2.0/24`
- Management subnet: `10.0.3.0/24`
- Private endpoint network policies: Disabled on all three subnets
- Application NSG attached to application subnet
- Management NSG attached to management subnet
- VNet private endpoint policies: Disabled

### Storage

- SKU: `Standard_LRS`
- HTTPS-only traffic: Enabled
- Minimum TLS version: `TLS1_2`
- Public blob access: Disabled
- Deployment container: `function-deployment`
- Container public access: None
- Default encryption scope: `$account-encryption-key`
- Encryption scope override: Disabled

### Identity and Access Management

The user-assigned managed identity `id-enterprise-ai` was verified against its existing role assignments.

Key Vault role:
- Key Vault Secrets User

Storage roles:
- Storage Blob Data Owner
- Storage Table Data Contributor
- Storage Blob Data Contributor

All four assignments were verified as ServicePrincipal assignments at their intended resource scopes.

## 3. Infrastructure-as-Code Validation

The deployment workflow included:

1. Bicep compilation.
2. GitHub Actions OIDC authentication.
3. Azure What-If preview.
4. Review of proposed resource changes.
5. Incremental deployment.
6. Post-deployment verification using Azure CLI.

The What-If preview showed four RBAC assignment modifications because the managed identity principal ID was represented as a resource reference. The existing principal ID and all four live role assignments were independently verified before deployment.

## 4. Deployment Scope and Limitations

The main Bicep template manages the network, identity, security, Key Vault, Storage, associations, and corresponding RBAC assignments.

The existing Azure AI Foundry resource and project, Function App, Application Insights, Log Analytics workspace, and GitHub Actions identity were outside this deployment template and were not redeployed.

The Function App's managed identity access to Key Vault had been tested separately. Application telemetry ingestion remains a separate validation item.

## 5. Outcome

The incremental deployment succeeded. Post-deployment checks confirmed that the existing network security settings, subnet associations, Storage security settings, container configuration, and RBAC assignments were preserved.

This deployment demonstrates modular Azure infrastructure provisioning, identity-based access control, infrastructure preview, CI/CD authentication, and post-deployment validation.

**Status:** Infrastructure foundation deployed and validated.