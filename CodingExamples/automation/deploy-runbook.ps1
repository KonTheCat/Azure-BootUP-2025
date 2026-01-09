# Deploy and Execute an Azure Automation Runbook
# This demonstrates creating and running a simple PowerShell runbook
# Key AZ-104 concept: Automation and resource management

# Variables
$resourceGroupName = "rg-automation-demo"
$automationAccountName = "aa-bootup-demo"
$runbookName = "Get-AzureVMStatus"

# Simple runbook content that gets VM status
# In production, you'd typically import from a file or repository
$runbookContent = @'
# This runbook lists all VMs and their power states in the subscription
# Uses the automation account's managed identity for authentication

# Connect using managed identity
Connect-AzAccount -Identity

# Get all VMs across all resource groups
$vms = Get-AzVM -Status

# Display VM information
foreach ($vm in $vms) {
    Write-Output "VM Name: $($vm.Name)"
    Write-Output "Resource Group: $($vm.ResourceGroupName)"
    Write-Output "Location: $($vm.Location)"
    Write-Output "Power State: $($vm.PowerState)"
    Write-Output "---"
}

Write-Output "Total VMs found: $($vms.Count)"
'@

# Create the runbook
Write-Host "Creating runbook: $runbookName" -ForegroundColor Green
New-AzAutomationRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $runbookName `
    -Type PowerShell `
    -Description "Lists all Azure VMs and their power states"

# Save the runbook content to a temporary file and import it
Write-Host "Importing runbook content..." -ForegroundColor Green
$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $runbookContent

Import-AzAutomationRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $runbookName `
    -Type PowerShell `
    -Path $tempFile `
    -Force

# Clean up temporary file
Remove-Item -Path $tempFile -Force

# Publish the runbook (required before it can be run)
Write-Host "Publishing runbook..." -ForegroundColor Green
Publish-AzAutomationRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $runbookName

# Start the runbook
Write-Host "Starting runbook execution..." -ForegroundColor Green
$job = Start-AzAutomationRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $runbookName

Write-Host "`nRunbook job started!" -ForegroundColor Cyan
Write-Host "Job ID: $($job.JobId)" -ForegroundColor Yellow
Write-Host "`nTo view job status, run:" -ForegroundColor Cyan
Write-Host "Get-AzAutomationJob -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Id $($job.JobId)" -ForegroundColor Yellow
