#!/bin/bash

##############################################################################
# Script de déploiement après correction de l'authentification
# À exécuter dans Azure Cloud Shell
##############################################################################

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Déploiement après correction de l'authentification           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Variables
RESOURCE_GROUP="rg-saasaccel-teams-gpt-02"
CUSTOMER_APP="sac-02-portal"
ADMIN_APP="sac-02-admin"
REPO_DIR="$HOME/Commercial-Marketplace-SaaS-Accelerator"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Customer Portal: $CUSTOMER_APP"
echo "   Admin Portal: $ADMIN_APP"
echo "   Repository: $REPO_DIR"
echo ""

# Étape 1: Clone ou pull du repo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📥 1. Récupération du code source"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "$REPO_DIR" ]; then
    echo "✓ Repository existe, mise à jour..."
    cd "$REPO_DIR"
    git fetch origin
    git reset --hard origin/main
    git pull origin main
else
    echo "✓ Clone du repository..."
    cd "$HOME"
    git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git
    cd "$REPO_DIR"
fi

echo "✓ Code à jour (commit: $(git rev-parse --short HEAD))"
echo ""

# Étape 2: Build Customer Portal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 2. Compilation du Customer Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$REPO_DIR"
dotnet publish src/CustomerSite/CustomerSite.csproj \
    -c Release \
    -o Publish/CustomerSite \
    --no-self-contained

if [ $? -eq 0 ]; then
    echo "✓ Customer Portal compilé avec succès"
else
    echo "✗ Erreur de compilation du Customer Portal"
    exit 1
fi
echo ""

# Étape 3: Package Customer Portal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 3. Création du package Customer Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$REPO_DIR/Publish/CustomerSite"
zip -r ../CustomerSite.zip . -q
cd "$REPO_DIR"

if [ -f "Publish/CustomerSite.zip" ]; then
    SIZE=$(ls -lh Publish/CustomerSite.zip | awk '{print $5}')
    echo "✓ Package créé: CustomerSite.zip ($SIZE)"
else
    echo "✗ Erreur lors de la création du package"
    exit 1
fi
echo ""

# Étape 4: Déploiement Customer Portal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 4. Déploiement du Customer Portal vers Azure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CUSTOMER_APP" \
    --src-path "Publish/CustomerSite.zip" \
    --type zip \
    --restart true \
    --async false

if [ $? -eq 0 ]; then
    echo "✓ Customer Portal déployé avec succès"
else
    echo "✗ Erreur lors du déploiement"
    exit 1
fi
echo ""

# Étape 5: Build Admin Portal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 5. Compilation de l'Admin Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$REPO_DIR"
dotnet publish src/AdminSite/AdminSite.csproj \
    -c Release \
    -o Publish/AdminSite \
    --no-self-contained

if [ $? -eq 0 ]; then
    echo "✓ Admin Portal compilé avec succès"
else
    echo "✗ Erreur de compilation de l'Admin Portal"
    exit 1
fi
echo ""

# Étape 6: Package Admin Portal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 6. Création du package Admin Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$REPO_DIR/Publish/AdminSite"
zip -r ../AdminSite.zip . -q
cd "$REPO_DIR"

if [ -f "Publish/AdminSite.zip" ]; then
    SIZE=$(ls -lh Publish/AdminSite.zip | awk '{print $5}')
    echo "✓ Package créé: AdminSite.zip ($SIZE)"
else
    echo "✗ Erreur lors de la création du package"
    exit 1
fi
echo ""

# Étape 7: Déploiement Admin Portal
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 7. Déploiement de l'Admin Portal vers Azure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ADMIN_APP" \
    --src-path "Publish/AdminSite.zip" \
    --type zip \
    --restart true \
    --async false

if [ $? -eq 0 ]; then
    echo "✓ Admin Portal déployé avec succès"
else
    echo "✗ Erreur lors du déploiement"
    exit 1
fi
echo ""

# Résumé
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  ✅ DÉPLOIEMENT TERMINÉ                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Résumé des changements:"
echo "   ✓ Azure App Service Auth désactivé"
echo "   ✓ OpenID Connect authentication rétabli dans le code"
echo "   ✓ BaseController.CheckAuthentication() restauré"
echo "   ✓ HomeController.Challenge() restauré"
echo "   ✓ Redirect URI /signin-oidc configuré"
echo ""
echo "🌐 URLs des portails:"
echo "   Customer Portal: https://$CUSTOMER_APP.azurewebsites.net"
echo "   Admin Portal:    https://$ADMIN_APP.azurewebsites.net"
echo ""
echo "🧪 Test recommandé:"
echo "   1. Ouvrir https://$CUSTOMER_APP.azurewebsites.net"
echo "   2. Vérifier la redirection vers Azure AD login"
echo "   3. Se connecter avec un compte Azure AD"
echo "   4. Vérifier l'accès à la landing page"
echo ""
echo "📝 Si l'authentification échoue encore, vérifier:"
echo "   - Les Application Settings dans le portail Azure"
echo "   - Les valeurs dans Azure App Configuration"
echo "   - Les logs de l'application: az webapp log tail -n $CUSTOMER_APP -g $RESOURCE_GROUP"
echo ""
