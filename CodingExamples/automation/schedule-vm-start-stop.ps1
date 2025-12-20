# Schedule VM Start/Stop using Azure Automation
# This demonstrates scheduling automation runbooks - key AZ-104 skill
# Useful for cost optimization by stopping VMs during non-business hours

# Variables
$resourceGroupName = "rg-automation-demo"
$automationAccountName = "aa-bootup-demo"
$runbookName = "Stop-AzureVM"
$scheduleName = "StopVMsEvening"
$targetVMResourceGroup = "rg-vms-production"
$targetVMName = "vm-webserver-01"

# Create a runbook for stopping a VM
$stopVMRunbookContent = @'
param(
    [Parameter(Mandatory=$true)]
    [string]$VMResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName
)

# Connect using managed identity
Connect-AzAccount -Identity

# Stop the specified VM
Write-Output "Stopping VM: $VMName in resource group: $VMResourceGroup"
Stop-AzVM -ResourceGroupName $VMResourceGroup -Name $VMName -Force

Write-Output "VM $VMName has been stopped successfully"
'@

# Create the runbook
Write-Host "Creating Stop VM runbook..." -ForegroundColor Green
New-AzAutomationRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $runbookName `
    -Type PowerShell `
    -Description "Stops a specified Azure VM"

# In production, you would import from a file
# Publish the runbook
Write-Host "Publishing runbook..." -ForegroundColor Green
Publish-AzAutomationRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $runbookName

# Create a schedule - Stop VMs every weekday at 6 PM
Write-Host "Creating schedule for VM shutdown..." -ForegroundColor Green
$startTime = (Get-Date "18:00").AddDays(1)
$schedule = New-AzAutomationSchedule `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -Name $scheduleName `
    -StartTime $startTime `
    -DayInterval 1 `
    -Description "Stop VMs at 6 PM every day"

# Link the schedule to the runbook with parameters
Write-Host "Linking schedule to runbook..." -ForegroundColor Green
$params = @{
    "VMResourceGroup" = $targetVMResourceGroup
    "VMName" = $targetVMName
}

Register-AzAutomationScheduledRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -RunbookName $runbookName `
    -ScheduleName $scheduleName `
    -Parameters $params

Write-Host "`nScheduled automation configured successfully!" -ForegroundColor Cyan
Write-Host "VM '$targetVMName' will be stopped daily at 6 PM" -ForegroundColor Yellow
Write-Host "`nKey AZ-104 concepts demonstrated:" -ForegroundColor Cyan
Write-Host "- Azure Automation runbooks" -ForegroundColor White
Write-Host "- Scheduling automation tasks" -ForegroundColor White
Write-Host "- Cost optimization through automation" -ForegroundColor White
Write-Host "- Using managed identities for authentication" -ForegroundColor White
