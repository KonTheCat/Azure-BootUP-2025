#!/bin/bash
# Create Azure Automation Account using Azure CLI
# This script demonstrates Azure Automation account creation
# Useful for AZ-104 exam preparation

# Variables - Update these for your environment
RESOURCE_GROUP="rg-automation-demo"
LOCATION="eastus"
AUTOMATION_ACCOUNT="aa-bootup-demo"

# Create resource group if it doesn't exist
echo "Creating resource group: $RESOURCE_GROUP"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION"

# Create Automation Account
# The Automation Account is the container for automation resources
echo "Creating Automation Account: $AUTOMATION_ACCOUNT"
az automation account create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$AUTOMATION_ACCOUNT" \
    --location "$LOCATION" \
    --sku Free

# Display the automation account details
echo -e "\nAutomation Account created successfully!"
az automation account show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$AUTOMATION_ACCOUNT" \
    --query "{Name:name, Location:location, State:state, ResourceGroup:resourceGroup}" \
    --output table

# Optional: Enable system-assigned managed identity
# Important for AZ-104 - understanding managed identities and RBAC
echo -e "\nEnabling system-assigned managed identity..."
az automation account update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$AUTOMATION_ACCOUNT" \
    --assign-identity

echo "Setup complete! You can now create runbooks in this automation account."
