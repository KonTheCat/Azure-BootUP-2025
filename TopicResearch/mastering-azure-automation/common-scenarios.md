# Common Azure Automation Scenarios

Practical examples of real-world automation scenarios for AZ-104 preparation.

## Table of Contents

1. [Cost Management Scenarios](#cost-management-scenarios)
2. [VM Management Scenarios](#vm-management-scenarios)
3. [Storage Management Scenarios](#storage-management-scenarios)
4. [Monitoring and Alerting](#monitoring-and-alerting)
5. [Compliance and Governance](#compliance-and-governance)

## Cost Management Scenarios

### Scenario 1: Auto-Shutdown Development VMs

**Business Need**: Reduce costs by automatically stopping development VMs after business hours.

**Solution Overview**:
- Create runbook to identify and stop VMs with specific tags
- Schedule runbook to run at 6 PM weekdays
- Send notification before shutdown

**Implementation**:
```powershell
param(
    [string]$TagName = "Environment",
    [string]$TagValue = "Development"
)

Connect-AzAccount -Identity

# Find all running VMs with the specified tag
$vms = Get-AzVM -Status | Where-Object {
    $_.Tags[$TagName] -eq $TagValue -and 
    $_.PowerState -eq "VM running"
}

foreach ($vm in $vms) {
    Write-Output "Stopping VM: $($vm.Name) in $($vm.ResourceGroupName)"
    Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force
}

Write-Output "Stopped $($vms.Count) development VMs"
```

**Schedule**: Daily at 18:00, Monday through Friday

**Cost Savings**: ~70% for VMs running 24/7 vs 10 hours/day

### Scenario 2: Resize Underutilized VMs

**Business Need**: Automatically identify and resize VMs with low CPU utilization.

**Solution**:
- Query Azure Monitor metrics for CPU usage
- Identify VMs with <10% average CPU over 7 days
- Resize to smaller SKU
- Send report to administrators

**Benefits**: 
- 30-50% cost reduction per resized VM
- Automated optimization without manual monitoring

## VM Management Scenarios

### Scenario 3: Automated VM Backup Verification

**Business Need**: Ensure all production VMs have backup enabled.

**Solution**:
```powershell
Connect-AzAccount -Identity

$productionVMs = Get-AzVM | Where-Object {$_.Tags.Environment -eq "Production"}
$unprotectedVMs = @()

foreach ($vm in $productionVMs) {
    $backupStatus = Get-AzRecoveryServicesBackupStatus `
        -ResourceGroupName $vm.ResourceGroupName `
        -Name $vm.Name `
        -Type "AzureVM"
    
    if (-not $backupStatus.BackedUp) {
        $unprotectedVMs += $vm.Name
        Write-Warning "VM not backed up: $($vm.Name)"
    }
}

if ($unprotectedVMs.Count -gt 0) {
    # Send alert or create incident
    Write-Output "Found $($unprotectedVMs.Count) unprotected VMs"
    # Could integrate with Logic Apps, SendGrid, or Teams webhook
}
```

**Schedule**: Daily at 8 AM

**Compliance Value**: Ensures disaster recovery readiness

### Scenario 4: VM Snapshot Automation

**Business Need**: Create snapshots of critical VMs before maintenance.

**Solution**:
- Runbook creates snapshots of all OS and data disks
- Tags snapshots with date and purpose
- Removes snapshots older than 7 days

**Use Cases**:
- Before applying updates
- Before configuration changes
- Before deploying new code

## Storage Management Scenarios

### Scenario 5: Blob Storage Lifecycle Management

**Business Need**: Automatically tier cold data to cool/archive storage.

**Solution**:
```powershell
Connect-AzAccount -Identity

$storageAccountName = "mystorageaccount"
$resourceGroup = "rg-storage"

$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroup `
    -Name $storageAccountName).Context

# Get all blobs not accessed in 90 days
$oldBlobs = Get-AzStorageBlob -Container "logs" -Context $context | 
    Where-Object {$_.LastModified -lt (Get-Date).AddDays(-90)}

foreach ($blob in $oldBlobs) {
    # Move to Cool tier
    $blob.ICloudBlob.SetStandardBlobTier("Cool")
    Write-Output "Moved $($blob.Name) to Cool tier"
}
```

**Cost Savings**: Cool storage is ~50% cheaper than Hot tier

### Scenario 6: Storage Account Cleanup

**Business Need**: Delete temporary files and old logs automatically.

**Patterns**:
- Delete files in /temp folders older than 7 days
- Delete log files older than 90 days
- Archive important files before deletion

## Monitoring and Alerting

### Scenario 7: Resource Health Monitoring

**Business Need**: Monitor and respond to Azure resource health issues.

**Solution**:
```powershell
Connect-AzAccount -Identity

$unhealthyResources = Get-AzResource | ForEach-Object {
    $health = Get-AzResourceHealth -ResourceId $_.ResourceId
    if ($health.AvailabilityState -ne "Available") {
        [PSCustomObject]@{
            Name = $_.Name
            Type = $_.ResourceType
            State = $health.AvailabilityState
            Reason = $health.ReasonType
        }
    }
}

if ($unhealthyResources) {
    # Send alert via Logic App, email, or Teams
    $unhealthyResources | Format-Table | Out-String | Write-Output
}
```

**Schedule**: Every 15 minutes

### Scenario 8: Disk Space Monitoring

**Business Need**: Alert when VM disks are running low on space.

**Solution**:
- Use Azure Monitor to collect disk metrics
- Runbook queries metrics and identifies VMs >85% disk usage
- Creates alerts or tickets automatically

## Compliance and Governance

### Scenario 9: Tag Compliance Enforcement

**Business Need**: Ensure all resources have required tags (Owner, CostCenter, Environment).

**Solution**:
```powershell
Connect-AzAccount -Identity

$requiredTags = @("Owner", "CostCenter", "Environment")
$nonCompliantResources = @()

$resources = Get-AzResource

foreach ($resource in $resources) {
    $missingTags = @()
    foreach ($tag in $requiredTags) {
        if (-not $resource.Tags.ContainsKey($tag)) {
            $missingTags += $tag
        }
    }
    
    if ($missingTags.Count -gt 0) {
        $nonCompliantResources += [PSCustomObject]@{
            Name = $resource.Name
            Type = $resource.ResourceType
            MissingTags = $missingTags -join ", "
        }
    }
}

Write-Output "Found $($nonCompliantResources.Count) non-compliant resources"
$nonCompliantResources | Format-Table | Out-String | Write-Output
```

**Action**: Generate report or automatically apply default tags

### Scenario 10: Unused Resource Cleanup

**Business Need**: Identify and remove unused resources to reduce costs.

**Targets**:
- NICs not attached to VMs
- Public IPs not associated with resources
- Unattached disks older than 30 days
- Empty resource groups

**Implementation**:
```powershell
Connect-AzAccount -Identity

# Find unattached NICs
$unusedNICs = Get-AzNetworkInterface | Where-Object {
    $_.VirtualMachine -eq $null
}

Write-Output "Found $($unusedNICs.Count) unused NICs"

# Find unassociated Public IPs
$unusedIPs = Get-AzPublicIpAddress | Where-Object {
    $_.IpConfiguration -eq $null
}

Write-Output "Found $($unusedIPs.Count) unused Public IPs"

# Find unattached disks
$unusedDisks = Get-AzDisk | Where-Object {
    $_.ManagedBy -eq $null -and 
    $_.TimeCreated -lt (Get-Date).AddDays(-30)
}

Write-Output "Found $($unusedDisks.Count) unused disks"

# Generate report or cleanup (with approval workflow)
```

**Cost Impact**: Can save 5-15% of monthly Azure spend

## Integration Patterns

### Scenario 11: Integration with Logic Apps

**Use Case**: Trigger automation runbook from external event.

**Flow**:
1. Logic App receives webhook/email/event
2. Logic App calls Azure Automation webhook
3. Runbook processes request
4. Runbook returns status to Logic App
5. Logic App sends notification

**Example**: On-demand VM deployment via email

### Scenario 12: Integration with Azure DevOps

**Use Case**: Run automation as part of CI/CD pipeline.

**Implementation**:
- Azure Pipelines task triggers runbook
- Runbook performs post-deployment tasks
- Pipeline waits for runbook completion
- Pipeline continues based on runbook status

**Example**: Post-deployment configuration, DNS updates, backup setup

## Advanced Patterns

### Scenario 13: Multi-Region Failover Automation

**Business Need**: Automate failover of services to secondary region.

**Components**:
- Health check runbook monitors primary region
- Failover runbook promotes secondary region
- DNS update runbook redirects traffic
- Notification runbook alerts stakeholders

### Scenario 14: Automated Incident Response

**Business Need**: Respond automatically to security or operational incidents.

**Triggers**:
- Azure Security Center alert
- Azure Sentinel incident
- Azure Monitor alert

**Actions**:
- Isolate compromised VM (change NSG rules)
- Create VM snapshot for forensics
- Trigger backup
- Notify security team
- Create incident ticket

## Best Practices Summary

1. **Always use managed identities** - Avoid hardcoded credentials
2. **Implement proper error handling** - Use try-catch blocks
3. **Log extensively** - Use Write-Output for tracking
4. **Make runbooks idempotent** - Safe to run multiple times
5. **Use parameters** - Make runbooks reusable
6. **Test thoroughly** - Use test environments first
7. **Monitor job execution** - Set up alerts for failures
8. **Version control runbooks** - Store in Git repository
9. **Document runbooks** - Clear comments and descriptions
10. **Regular reviews** - Audit runbooks quarterly

## Testing Your Runbooks

### Test Checklist

- [ ] Test with valid inputs
- [ ] Test with invalid inputs
- [ ] Test error handling
- [ ] Test with no matching resources
- [ ] Test with multiple resources
- [ ] Verify RBAC permissions
- [ ] Check execution time
- [ ] Verify all outputs
- [ ] Test scheduled execution
- [ ] Test with parameters

### Common Pitfalls to Avoid

1. **No error handling** - Runbook fails without useful message
2. **Hardcoded values** - Makes runbook inflexible
3. **No logging** - Difficult to troubleshoot issues
4. **Insufficient permissions** - Runbook fails due to RBAC
5. **No testing** - Runbook fails in production
6. **Synchronous waits** - Runbook times out on long operations
7. **No versioning** - Can't roll back changes
8. **Excessive permissions** - Security risk with broad RBAC

## Exam Tips

For AZ-104, be prepared to:
- Identify appropriate automation scenarios
- Choose between runbook types (PowerShell, Python, Graphical)
- Configure authentication methods (managed identity preferred)
- Set up schedules and webhooks
- Troubleshoot failed runbook executions
- Implement Update Management
- Configure Hybrid Runbook Workers
- Use automation assets (variables, credentials)

## Additional Resources

- [Azure Automation Best Practices](https://learn.microsoft.com/en-us/azure/automation/automation-runbook-execution)
- [Runbook Gallery](https://github.com/azureautomation)
- [Azure Automation Pricing](https://azure.microsoft.com/en-us/pricing/details/automation/)
