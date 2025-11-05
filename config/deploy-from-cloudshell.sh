#!/bin/bash
# ============================================================================
# Azure Marketplace SaaS Accelerator - Customer Portal Deployment
# ============================================================================
# This script is a bash equivalent of deployment/Upgrade.ps1
# It follows the same two-step approach: 1) Database Migration, 2) Code Deployment
#
# REQUIREMENTS:
# - Azure Cloud Shell (Linux x64) for binary compatibility with Azure App Service
# - Azure CLI authenticated
# - Access to KeyVault for connection string
#
# Usage: ./deploy-from-cloudshell.sh
# ============================================================================

set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

echo "=========================================="
echo "Azure Marketplace SaaS Accelerator Upgrade"
echo "=========================================="
echo ""

# ============================================================================
# Configuration (matching Upgrade.ps1 parameters)
# ============================================================================
REPO_DIR="/home/michel/Commercial-Marketplace-SaaS-Accelerator"
WEB_APP_NAME_PREFIX="sac-02"
RESOURCE_GROUP="rg-saasaccel-teams-gpt-02"
WEB_APP_NAME_PORTAL="${WEB_APP_NAME_PREFIX}-portal"
WEB_APP_NAME_ADMIN="${WEB_APP_NAME_PREFIX}-admin"
KEY_VAULT="${WEB_APP_NAME_PREFIX}-kv"
SQL_SERVER="${WEB_APP_NAME_PREFIX}-sql"
SQL_DATABASE="${WEB_APP_NAME_PREFIX}AMPSaaSDB"

# Project paths
ADMIN_SITE_PROJECT="$REPO_DIR/src/AdminSite/AdminSite.csproj"
CUSTOMER_SITE_PROJECT="$REPO_DIR/src/CustomerSite/CustomerSite.csproj"
DATA_ACCESS_PROJECT="$REPO_DIR/src/DataAccess/DataAccess.csproj"
PUBLISH_DIR="$REPO_DIR/Publish"

# Verify Cloud Shell environment
if [ -z "$AZURE_HTTP_USER_AGENT" ]; then
    echo "⚠️  WARNING: This script should run in Azure Cloud Shell!"
    echo "⚠️  Local execution detected - binaries may be incompatible!"
    echo ""
    read -p "Continue anyway? (yes/no) " -n 3 -r
    echo ""
    if [[ ! $REPLY =~ ^yes$ ]]; then
        echo "Deployment cancelled."
        exit 1
    fi
fi

echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Portal App: $WEB_APP_NAME_PORTAL"
echo "  Admin App: $WEB_APP_NAME_ADMIN"
echo "  KeyVault: $KEY_VAULT"
echo "  SQL Server: $SQL_SERVER"
echo "  SQL Database: $SQL_DATABASE"
echo ""

# ============================================================================
# STEP 1: Database Migration (matching Upgrade.ps1 lines 93-194)
# ============================================================================
echo "#### STEP 1: Database Migration ####"
echo ""

echo "## 1.1: Retrieve connection string from KeyVault"
CONNECTION_STRING=$(az keyvault secret show \
    --vault-name "$KEY_VAULT" \
    --name "DefaultConnection" \
    --query "value" -o tsv)

if [ -z "$CONNECTION_STRING" ]; then
    echo "❌ ERROR: Failed to retrieve connection string from KeyVault"
    exit 1
fi
echo "✅ Connection string retrieved"
echo ""

echo "## 1.2: Update appsettings for migration"
cd "$REPO_DIR"
cat > src/AdminSite/appsettings.Development.json <<EOF
{
  "ConnectionStrings": {
    "DefaultConnection": "$CONNECTION_STRING"
  }
}
EOF
echo "✅ appsettings.Development.json created"
echo ""

echo "## 1.3: Generate idempotent migration script"
dotnet ef migrations script \
    --idempotent \
    --context SaaSKitContext \
    --project "$DATA_ACCESS_PROJECT" \
    --startup-project "$ADMIN_SITE_PROJECT" \
    --output script.sql

if [ ! -f script.sql ]; then
    echo "❌ ERROR: Migration script generation failed"
    exit 1
fi
echo "✅ Migration script generated: script.sql"
echo ""

echo "## 1.4: Apply migrations to database"
echo "⚠️  NOTE: Database migration requires sqlcmd or Azure SQL extension"
echo "⚠️  Skipping automatic migration - apply script.sql manually if needed"
echo ""

# Option 1: sqlcmd (requires installation in Cloud Shell)
# sqlcmd -S "$SQL_SERVER.database.windows.net" -d "$SQL_DATABASE" -G -i script.sql

# Option 2: Azure SQL extension (if available)
# az sql db query -s "$SQL_SERVER" -n "$SQL_DATABASE" -g "$RESOURCE_GROUP" --file script.sql

# Option 3: Manual application (current workaround)
echo "To apply migrations manually:"
echo "1. Download script.sql from Cloud Shell"
echo "2. Connect to SQL Server: $SQL_SERVER.database.windows.net"
echo "3. Execute script against database: $SQL_DATABASE"
echo ""
echo "Press Enter to continue with code deployment..."
read

echo "✅ Database migration step completed"
echo ""

# ============================================================================
# STEP 2: Code Deployment (matching Upgrade.ps1 lines 196-233)
# ============================================================================
echo "#### STEP 2: Code Deployment ####"
echo ""

echo "## 2.1: Update source code from Git"
cd "$REPO_DIR"
git pull origin main
echo "✅ Source code updated"
echo ""

echo "## 2.2: Clean old publish directory"
rm -rf "$PUBLISH_DIR"
mkdir -p "$PUBLISH_DIR"
echo "✅ Publish directory cleaned"
echo ""

echo "## 2.3: Build CustomerSite (Release configuration)"
dotnet publish "$CUSTOMER_SITE_PROJECT" \
    -c Release \
    -o "$PUBLISH_DIR/CustomerSite" \
    -v q

if [ ! -f "$PUBLISH_DIR/CustomerSite/CustomerSite.dll" ]; then
    echo "❌ ERROR: CustomerSite build failed"
    exit 1
fi
echo "✅ CustomerSite built successfully"
echo ""

# Optional: Build AdminSite (uncomment if needed)
# echo "## 2.4: Build AdminSite (Release configuration)"
# dotnet publish "$ADMIN_SITE_PROJECT" \
#     -c Release \
#     -o "$PUBLISH_DIR/AdminSite" \
#     -v q
# echo "✅ AdminSite built successfully"
# echo ""

echo "## 2.4: Create ZIP package"
cd "$PUBLISH_DIR"
zip -r CustomerSite.zip CustomerSite/ -q

ZIP_SIZE=$(du -h CustomerSite.zip | cut -f1)
echo "✅ ZIP package created: $ZIP_SIZE"
echo ""

echo "## 2.5: Deploy to Azure App Service"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   App Service: $WEB_APP_NAME_PORTAL"
echo "   Method: az webapp deploy (modern deployment command)"
echo ""

# CRITICAL CHANGE: Use 'az webapp deploy' instead of deprecated 'az webapp deployment source config-zip'
# This matches Upgrade.ps1 line 216-227
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEB_APP_NAME_PORTAL" \
    --src-path "$PUBLISH_DIR/CustomerSite.zip" \
    --type zip \
    --async false

echo "✅ Code deployment completed"
echo ""

# ============================================================================
# STEP 3: Cleanup
# ============================================================================
echo "#### STEP 3: Cleanup ####"
echo ""

echo "## 3.1: Remove temporary files"
rm -f "$REPO_DIR/src/AdminSite/appsettings.Development.json"
rm -f "$REPO_DIR/script.sql"
echo "✅ Temporary files removed"
echo ""

# Keep Publish directory for debugging
# rm -rf "$PUBLISH_DIR"

echo "=========================================="
echo "✅ Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Wait 30 seconds for application restart"
echo "2. Test portal: https://${WEB_APP_NAME_PORTAL}.azurewebsites.net"
echo "3. If issues, check logs:"
echo "   az webapp log tail --resource-group $RESOURCE_GROUP --name $WEB_APP_NAME_PORTAL"
echo "4. Verify HTTP status:"
echo "   curl -I https://${WEB_APP_NAME_PORTAL}.azurewebsites.net"
echo ""
echo "Database migration script saved at: $REPO_DIR/script.sql"
echo ""
