#!/bin/bash
# Azure Automation Update Management Example
# Demonstrates configuring update management for Azure VMs
# Important for AZ-104: Monitoring and maintaining Azure resources

# Variables
RESOURCE_GROUP="rg-automation-demo"
AUTOMATION_ACCOUNT="aa-bootup-demo"
LOCATION="eastus"
VM_RESOURCE_GROUP="rg-vms-production"
VM_NAME="vm-webserver-01"

# Note: Update Management requires a Log Analytics workspace
WORKSPACE_NAME="law-automation-updates"

# Create Log Analytics workspace if it doesn't exist
echo "Creating Log Analytics workspace: $WORKSPACE_NAME"
az monitor log-analytics workspace create \
    --resource-group "$RESOURCE_GROUP" \
    --workspace-name "$WORKSPACE_NAME" \
    --location "$LOCATION"

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --resource-group "$RESOURCE_GROUP" \
    --workspace-name "$WORKSPACE_NAME" \
    --query customerId \
    --output tsv)

echo "Log Analytics Workspace ID: $WORKSPACE_ID"

# Link the Automation Account to the Log Analytics workspace
# This enables Update Management, Change Tracking, and Inventory
echo -e "\nLinking Automation Account to Log Analytics workspace..."
az automation account update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$AUTOMATION_ACCOUNT" \
    --assign-identity

# Note: Full Update Management configuration typically requires additional steps
# including enabling the Update Management solution in the workspace

echo -e "\nUpdate Management foundation configured!"
echo "Next steps for full setup:"
echo "1. Enable Update Management solution in the Azure portal"
echo "2. Onboard VMs to Update Management"
echo "3. Create update schedules"
echo "4. Review update compliance"

echo -e "\nKey AZ-104 concepts covered:"
echo "- Azure Automation Update Management"
echo "- Log Analytics workspace integration"
echo "- VM patch management"
echo "- Compliance monitoring"

# Example: Get VM update assessment (requires VM to be onboarded)
echo -e "\nTo check VM update status after onboarding, use:"
echo "az vm run-command invoke \\"
echo "    --resource-group $VM_RESOURCE_GROUP \\"
echo "    --name $VM_NAME \\"
echo "    --command-id RunPowerShellScript \\"
echo "    --scripts 'Get-HotFix | Select-Object -Last 10'"
