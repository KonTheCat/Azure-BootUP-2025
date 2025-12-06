#!/bin/bash

# ==================================================================================
# Azure BootUP 2025 - Coding Example
# Topic: Containers & App Service
# Description: Create a .NET Web App, Containerize it, and Deploy to Azure Container Instances (ACI)
#              using ONLY Azure Cloud Shell (no local Docker required).
#
# Reference: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task
# ==================================================================================

# 1. Set Variables
# ----------------
# Use a unique name for your registry (must be globally unique)
RND=$RANDOM
RG_NAME="rg-azbootup-containers-$RND"
ACR_NAME="acrbootup$RND"
ACI_NAME="aci-bootup-app-$RND"
LOCATION="eastus"
IMAGE_NAME="hello-dotnet:v1"

echo "Setting up environment..."
echo "Resource Group: $RG_NAME"
echo "ACR Name:       $ACR_NAME"
echo "ACI Name:       $ACI_NAME"

# 2. Create Resource Group
# ------------------------
echo "Creating Resource Group..."
az group create --name $RG_NAME --location $LOCATION

# 3. Create a .NET Web App (Source Code)
# --------------------------------------
# We use the dotnet CLI available in Cloud Shell to scaffold a new web app
echo "Creating .NET Web App..."
dotnet new webapp -o my-dotnet-app
cd my-dotnet-app

# 4. Create a Dockerfile
# ----------------------
# We create a Dockerfile on the fly. This uses the official .NET images.
echo "Creating Dockerfile..."
cat <<EOF > Dockerfile
# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

# Use the ASP.NET runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "my-dotnet-app.dll"]
EOF

# 5. Create Azure Container Registry (ACR)
# ----------------------------------------
echo "Creating Azure Container Registry..."
az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic --admin-enabled true

# 6. Build Image in Azure (ACR Tasks)
# -----------------------------------
# This is the "magic" step. Instead of 'docker build' (which runs locally),
# 'az acr build' zips up the current directory, sends it to Azure, and builds it there.
echo "Building Docker Image in ACR (this may take a few minutes)..."
az acr build --registry $ACR_NAME --image $IMAGE_NAME .

# 7. Deploy to Azure Container Instances (ACI)
# --------------------------------------------
# We need the ACR credentials to pull the image.
# Since we enabled admin user, we can fetch the password.
echo "Getting ACR Credentials..."
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

echo "Deploying to Azure Container Instances..."
az container create \
    --resource-group $RG_NAME \
    --name $ACI_NAME \
    --image $ACR_NAME.azurecr.io/$IMAGE_NAME \
    --registry-login-server $ACR_NAME.azurecr.io \
    --registry-username $ACR_NAME \
    --registry-password $ACR_PASSWORD \
    --dns-name-label $ACI_NAME \
    --ports 8080 \
    --environment-variables ASPNETCORE_HTTP_PORTS=8080

# 8. Verify Deployment
# --------------------
echo "Deployment Complete!"
FQDN=$(az container show --resource-group $RG_NAME --name $ACI_NAME --query ipAddress.fqdn -o tsv)
echo "You can access your app at: http://$FQDN:8080"

# Optional: Clean up
# echo "To clean up, run: az group delete --name $RG_NAME --yes --no-wait"
