#!/bin/bash

# ╔══════════════════════════════════════════════════════════════╗
# ║  Customer Portal Deployment Script for Azure Cloud Shell     ║
# ║  Corrects ZIP structure and deploys to Azure App Service     ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESOURCE_GROUP="rg-saasaccel-teams-gpt-02"
WEBAPP_NAME="sac-02-portal"
PUBLISH_DIR="$HOME/Commercial-Marketplace-SaaS-Accelerator/Publish"
CUSTOMER_SITE_DIR="$PUBLISH_DIR/CustomerSite"
ZIP_FILE="$PUBLISH_DIR/CustomerSite.zip"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Customer Portal Deployment to Azure                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Check if CustomerSite directory exists
if [ ! -d "$CUSTOMER_SITE_DIR" ]; then
    echo -e "${RED}❌ ERROR: CustomerSite directory not found at $CUSTOMER_SITE_DIR${NC}"
    echo -e "${YELLOW}Please ensure the published files are in the Publish/CustomerSite directory${NC}"
    exit 1
fi

# Navigate to CustomerSite directory
cd "$CUSTOMER_SITE_DIR"
echo -e "${GREEN}✓ Found CustomerSite directory${NC}"
echo -e "${BLUE}Location: $CUSTOMER_SITE_DIR${NC}"
echo

# Create ZIP with files at root (not in a subfolder)
echo -e "${YELLOW}📦 Creating deployment package...${NC}"
rm -f "$ZIP_FILE"
zip -r "$ZIP_FILE" * .??* > /dev/null 2>&1 || true

if [ -f "$ZIP_FILE" ]; then
    SIZE=$(du -h "$ZIP_FILE" | cut -f1)
    echo -e "${GREEN}✓ Package created: CustomerSite.zip ($SIZE)${NC}"
    echo
else
    echo -e "${RED}❌ Failed to create ZIP file${NC}"
    exit 1
fi

# Deploy to Azure using az webapp deploy
echo -e "${YELLOW}🚀 Deploying to Azure App Service...${NC}"
echo -e "${BLUE}Resource Group: $RESOURCE_GROUP${NC}"
echo -e "${BLUE}Web App: $WEBAPP_NAME${NC}"
echo

cd "$PUBLISH_DIR"
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEBAPP_NAME" \
    --src-path CustomerSite.zip \
    --type zip \
    --restart true

if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ✓ DEPLOYMENT SUCCESSFUL                        ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}🌐 Customer Portal URL:${NC}"
    echo -e "${BLUE}   https://${WEBAPP_NAME}.azurewebsites.net${NC}"
    echo
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "   1. Wait 30-60 seconds for the app to restart"
    echo -e "   2. Test authentication at the URL above"
    echo -e "   3. Monitor logs if issues persist:"
    echo -e "      ${BLUE}az webapp log tail -n $WEBAPP_NAME -g $RESOURCE_GROUP${NC}"
else
    echo
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                  ❌ DEPLOYMENT FAILED                       ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}📋 Troubleshooting:${NC}"
    echo -e "   Check deployment logs:"
    echo -e "   ${BLUE}az webapp log deployment show -n $WEBAPP_NAME -g $RESOURCE_GROUP${NC}"
    echo
    exit 1
fi
