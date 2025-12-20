# Create Azure Automation Account
# This script demonstrates how to create an Azure Automation account using PowerShell
# Useful for AZ-104 exam preparation - automation and resource management

# Variables - Update these for your environment
$resourceGroupName = "rg-automation-demo"
$location = "eastus"
$automationAccountName = "aa-bootup-demo"

# Create resource group if it doesn't exist
Write-Host "Creating resource group: $resourceGroupName" -ForegroundColor Green
New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

# Create Automation Account
# The Automation Account is the container for automation resources
Write-Host "Creating Automation Account: $automationAccountName" -ForegroundColor Green
$automationAccount = New-AzAutomationAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $automationAccountName `
    -Location $location `
    -Plan Free

# Display the automation account details
Write-Host "`nAutomation Account created successfully!" -ForegroundColor Cyan
Write-Host "Name: $($automationAccount.AutomationAccountName)" -ForegroundColor Yellow
Write-Host "Resource Group: $($automationAccount.ResourceGroupName)" -ForegroundColor Yellow
Write-Host "Location: $($automationAccount.Location)" -ForegroundColor Yellow
Write-Host "State: $($automationAccount.State)" -ForegroundColor Yellow

# Optional: Enable system-assigned managed identity for the automation account
# This is important for AZ-104 - understanding managed identities
Write-Host "`nEnabling system-assigned managed identity..." -ForegroundColor Green
Set-AzAutomationAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $automationAccountName `
    -AssignSystemIdentity

Write-Host "Setup complete! You can now create runbooks in this automation account." -ForegroundColor Cyan
