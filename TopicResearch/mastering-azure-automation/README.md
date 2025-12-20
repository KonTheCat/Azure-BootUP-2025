# Mastering Azure Automation

A comprehensive guide to Azure Automation for the AZ-104 Azure Administrator certification.

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
3. [Automation Accounts](#automation-accounts)
4. [Runbooks](#runbooks)
5. [Automation Assets](#automation-assets)
6. [Update Management](#update-management)
7. [Change Tracking and Inventory](#change-tracking-and-inventory)
8. [Hybrid Runbook Worker](#hybrid-runbook-worker)
9. [Best Practices](#best-practices)
10. [AZ-104 Exam Focus](#az-104-exam-focus)

## Overview

Azure Automation is a cloud-based automation and configuration service that provides consistent management across your Azure and non-Azure environments. It enables process automation, configuration management, and update management.

### Key Benefits
- **Cost Reduction**: Automate repetitive tasks to reduce manual labor
- **Reliability**: Eliminate human errors with consistent automation
- **Compliance**: Ensure resources meet organizational standards
- **Time Savings**: Free up administrators for higher-value work

## Core Concepts

### What is Azure Automation?

Azure Automation delivers a cloud-based automation service that supports consistent management across Azure and non-Azure environments. It consists of:

1. **Process Automation**: Automate frequent, time-consuming, error-prone tasks
2. **Configuration Management**: Maintain desired state across resources
3. **Update Management**: Manage OS updates for Windows and Linux VMs

### Architecture Components

```
Azure Automation Account
├── Runbooks (PowerShell, Python, Graphical)
├── Schedules
├── Assets
│   ├── Variables
│   ├── Credentials
│   ├── Certificates
│   └── Connections
├── Modules
├── Webhooks
└── Jobs (execution history)
```

## Automation Accounts

An **Automation Account** is the container for all your automation resources.

### Key Properties
- **Location**: Azure region where metadata is stored
- **Pricing**: Free tier (500 minutes/month) or pay-as-you-go
- **Identity**: Can have system-assigned or user-assigned managed identity
- **Run As Account**: (Classic, being deprecated) - Use managed identities instead

### Creating an Automation Account

**Portal Steps:**
1. Navigate to Azure Portal > Create a resource
2. Search for "Automation"
3. Fill in: Name, Subscription, Resource Group, Location
4. Enable system-assigned managed identity
5. Review + Create

**PowerShell:**
```powershell
New-AzAutomationAccount -ResourceGroupName "rg-automation" `
    -Name "aa-example" -Location "eastus" -AssignSystemIdentity
```

**Azure CLI:**
```bash
az automation account create --resource-group "rg-automation" \
    --name "aa-example" --location "eastus" --assign-identity
```

### RBAC for Automation Accounts

Grant the automation account's managed identity appropriate permissions:
- **Reader**: View resources
- **Contributor**: Manage resources
- **Virtual Machine Contributor**: Manage VMs specifically
- **Custom roles**: For least-privilege access

## Runbooks

Runbooks are the core of Azure Automation - they contain the automation logic.

### Runbook Types

1. **PowerShell Runbooks**
   - Most common type
   - Run native PowerShell code
   - Support all Azure PowerShell cmdlets
   - Best for Azure resource management

2. **Python Runbooks**
   - Support Python 2 and Python 3
   - Good for cross-platform scripts
   - Can use Python packages

3. **Graphical Runbooks**
   - Visual workflow designer
   - No coding required
   - Based on PowerShell Workflow
   - Good for non-programmers

4. **PowerShell Workflow Runbooks** (Legacy)
   - Support checkpoints and parallel execution
   - Being deprecated in favor of PowerShell 7

### Runbook Lifecycle

1. **Create**: Define the runbook type and name
2. **Edit**: Write or import the automation code
3. **Publish**: Make the runbook available for execution
4. **Execute**: Run manually or on a schedule
5. **Monitor**: Track job status and output

### Authentication in Runbooks

**Managed Identity (Recommended):**
```powershell
# Connect using system-assigned managed identity
Connect-AzAccount -Identity

# Use Azure resources
Get-AzVM -ResourceGroupName "my-rg"
```

**Run As Account (Deprecated):**
```powershell
$connection = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID `
    -ApplicationId $connection.ApplicationID `
    -CertificateThumbprint $connection.CertificateThumbprint
```

### Input Parameters

Runbooks can accept parameters for flexibility:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$VMName = "default-vm"
)

Connect-AzAccount -Identity
Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force
```

## Automation Assets

Assets are resources available to all runbooks in an automation account.

### Variables

Store reusable values:
```powershell
# Create a variable
New-AzAutomationVariable -ResourceGroupName "rg" `
    -AutomationAccountName "aa" -Name "SubscriptionId" `
    -Value "xxxx-xxxx" -Encrypted $false

# Use in runbook
$subId = Get-AutomationVariable -Name "SubscriptionId"
```

### Credentials

Store username/password securely:
```powershell
# Create credential
$credential = Get-Credential
New-AzAutomationCredential -ResourceGroupName "rg" `
    -AutomationAccountName "aa" -Name "AdminCred" `
    -Value $credential

# Use in runbook
$cred = Get-AutomationPSCredential -Name "AdminCred"
```

### Certificates

Store and use certificates for authentication:
```powershell
New-AzAutomationCertificate -ResourceGroupName "rg" `
    -AutomationAccountName "aa" -Name "MyCert" `
    -Path "C:\cert.pfx" -Password $securePassword
```

### Connections

Store connection information for external services:
```powershell
$connectionValues = @{
    "ServerName" = "sql.contoso.com"
    "Database" = "mydb"
}
New-AzAutomationConnection -ResourceGroupName "rg" `
    -AutomationAccountName "aa" -Name "SqlConnection" `
    -ConnectionTypeName "SqlServer" -ConnectionFieldValues $connectionValues
```

## Update Management

Update Management provides visibility and control over OS updates.

### Features
- **Update Assessment**: View available updates for VMs
- **Update Deployment**: Schedule update installations
- **Compliance Dashboard**: See which VMs are compliant
- **Reboot Management**: Control when VMs restart
- **Pre/Post Scripts**: Run scripts before/after updates

### Prerequisites
- Log Analytics workspace
- Automation account linked to workspace
- VMs onboarded to Update Management
- Microsoft Monitoring Agent (or Azure Monitor Agent)

### Supported Operating Systems
- Windows Server 2012 and later
- Windows Client (with specific editions)
- Ubuntu 14.04 LTS and later
- CentOS 6 and later
- Red Hat Enterprise Linux 6 and later
- SUSE Linux Enterprise Server 12 and later

### Creating an Update Deployment

1. **Assessment Phase**: Automation scans VMs for available updates
2. **Classification**: Filter by Critical, Security, Updates, etc.
3. **Schedule**: Define when updates should install
4. **Maintenance Window**: Set maximum duration (30 min to 6 hours)
5. **Reboot Options**: Always, IfRequired, Never, Manual

### Update Classifications

**Windows:**
- Critical updates
- Security updates
- Update rollups
- Feature packs
- Service packs
- Definition updates
- Tools and drivers

**Linux:**
- Critical and security updates
- Other updates

## Change Tracking and Inventory

Track changes to software, files, registry, and services.

### What's Tracked
- **Windows Services**: Service state changes
- **Linux Daemons**: Daemon configuration
- **Windows Software**: Installed/removed programs
- **Files**: Content changes to specified files
- **Registry Keys**: Windows registry modifications

### Use Cases
- **Compliance**: Verify no unauthorized changes
- **Troubleshooting**: Identify what changed before an issue
- **Audit**: Maintain change history for governance

### Configuration

1. Enable Change Tracking in Automation Account
2. Link to Log Analytics workspace
3. Onboard VMs
4. Configure which files/registry keys to track
5. Review changes in the portal or via Log Analytics queries

## Hybrid Runbook Worker

Extend Azure Automation to on-premises or other cloud environments.

### Architecture
```
Azure Automation Account
    ↓
Hybrid Runbook Worker Group
    ↓
├── Worker 1 (Windows/Linux)
├── Worker 2 (Windows/Linux)
└── Worker 3 (Windows/Linux)
```

### Use Cases
- Manage on-premises resources
- Access resources in private networks
- Comply with data residency requirements
- Use local tools and scripts

### Requirements
- Windows Server 2012 R2 or later, or Linux
- Log Analytics agent installed
- Network connectivity to Azure
- PowerShell 5.1 (Windows) or Python 2.7/3.6+ (Linux)

### Setup Steps
1. Create Log Analytics workspace
2. Install Log Analytics agent on target machine
3. Import required modules
4. Create Hybrid Worker Group
5. Add machine to group
6. Target runbooks to the hybrid worker

## Best Practices

### Security
- **Use Managed Identities**: Avoid storing credentials in runbooks
- **RBAC**: Grant least-privilege access to automation accounts
- **Encrypt Variables**: Mark sensitive variables as encrypted
- **Audit Logs**: Enable diagnostic logging for automation accounts

### Runbook Design
- **Idempotent**: Design runbooks to be safely re-runnable
- **Error Handling**: Use try-catch blocks and proper error handling
- **Logging**: Write meaningful output for troubleshooting
- **Modular**: Break complex automation into multiple runbooks
- **Parameters**: Make runbooks configurable with parameters

### Performance
- **Modules**: Only import modules you need
- **Job Limits**: Be aware of concurrent job limits (30 jobs per account)
- **Long-Running**: Consider Hybrid Workers for tasks >3 hours
- **Checkpoints**: Use checkpoints for lengthy operations (PowerShell Workflow)

### Cost Optimization
- **Free Tier**: Use 500 free minutes/month effectively
- **Scheduling**: Run jobs during off-peak hours
- **Monitoring**: Track job execution time
- **Cleanup**: Delete old jobs and unused runbooks

### Monitoring
- **Job Status**: Regularly check job completion status
- **Alerts**: Set up alerts for failed jobs
- **Metrics**: Monitor job duration and frequency
- **Logs**: Export to Log Analytics for long-term retention

## AZ-104 Exam Focus

### Key Topics to Master

1. **Create and Configure Automation Accounts**
   - Creating automation accounts via Portal, PowerShell, CLI
   - Configuring managed identities
   - Linking to Log Analytics workspace

2. **Manage Runbooks**
   - Creating PowerShell and Python runbooks
   - Publishing and executing runbooks
   - Scheduling runbook execution
   - Passing parameters to runbooks

3. **Manage Update Management**
   - Enabling Update Management solution
   - Onboarding VMs to Update Management
   - Creating update deployments
   - Configuring update schedules

4. **Authentication and Authorization**
   - Using managed identities (recommended)
   - Granting RBAC permissions to automation accounts
   - Understanding Run As accounts (legacy)

5. **Automation Assets**
   - Creating and using variables
   - Managing credentials securely
   - Working with certificates and connections

6. **Monitoring and Troubleshooting**
   - Viewing job history and status
   - Reviewing job output and errors
   - Setting up alerts for failed jobs
   - Using Log Analytics for automation logs

### Common Exam Scenarios

**Scenario 1: Automate VM Management**
- Create runbook to stop VMs during off-hours
- Schedule runbook execution
- Use managed identity for authentication
- Grant VM Contributor role to automation account

**Scenario 2: Update Management**
- Enable Update Management for a group of VMs
- Create update deployment schedule
- Configure maintenance window
- Review update compliance

**Scenario 3: Hybrid Automation**
- Set up Hybrid Runbook Worker
- Execute runbook on on-premises server
- Access local resources from runbook
- Troubleshoot connectivity issues

### Hands-On Practice

1. Create an automation account with managed identity
2. Write a runbook that lists all VMs and their power states
3. Schedule a runbook to run daily
4. Configure Update Management for a test VM
5. Create a runbook that uses automation variables
6. Set up Change Tracking for a VM
7. Review job history and troubleshoot a failed job

### Important PowerShell Cmdlets

```powershell
# Automation Account
New-AzAutomationAccount
Get-AzAutomationAccount
Set-AzAutomationAccount
Remove-AzAutomationAccount

# Runbooks
New-AzAutomationRunbook
Import-AzAutomationRunbook
Publish-AzAutomationRunbook
Start-AzAutomationRunbook
Get-AzAutomationRunbook

# Jobs
Get-AzAutomationJob
Get-AzAutomationJobOutput
Stop-AzAutomationJob

# Schedules
New-AzAutomationSchedule
Register-AzAutomationScheduledRunbook

# Assets
New-AzAutomationVariable
Get-AutomationVariable
New-AzAutomationCredential
Get-AutomationPSCredential
```

## Additional Resources

### Microsoft Learn Paths
- [Automate Azure tasks using scripts with PowerShell](https://learn.microsoft.com/en-us/training/paths/automate-tasks-powershell/)
- [Implement Azure Automation](https://learn.microsoft.com/en-us/training/modules/implement-azure-automation/)
- [Manage virtual machines with Azure CLI](https://learn.microsoft.com/en-us/training/modules/manage-virtual-machines-with-azure-cli/)

### Documentation
- [Azure Automation Documentation](https://learn.microsoft.com/en-us/azure/automation/)
- [Update Management Overview](https://learn.microsoft.com/en-us/azure/automation/update-management/overview)
- [Hybrid Runbook Worker Overview](https://learn.microsoft.com/en-us/azure/automation/automation-hybrid-runbook-worker)

### Labs
- [Microsoft Certification Hub - AZ-104 Labs](https://certs.msfthub.wiki/labs/azure/az-104/)
- Practice deploying automation accounts
- Create and schedule runbooks
- Configure Update Management

## Summary

Azure Automation is a critical service for Azure administrators, enabling:
- **Automation** of repetitive tasks
- **Consistency** across environments
- **Cost savings** through efficient resource management
- **Compliance** through update management and change tracking

For the AZ-104 exam, focus on:
- Creating and configuring automation accounts
- Writing and scheduling runbooks
- Using managed identities for authentication
- Implementing Update Management
- Understanding when to use Hybrid Runbook Workers

Practice hands-on scenarios to solidify your understanding!
