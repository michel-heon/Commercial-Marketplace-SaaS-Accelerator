#!/bin/bash
# ============================================================================
# Script de déploiement du Customer Portal depuis Azure Cloud Shell
# ============================================================================
# Ce script DOIT être exécuté depuis Azure Cloud Shell (Linux x64)
# pour garantir la compatibilité des binaires avec Azure App Service (Windows x64)
#
# Usage: ./deploy-from-cloudshell.sh
# ============================================================================

set -e  # Arrêter sur erreur

echo "=========================================="
echo "Déploiement Customer Portal"
echo "=========================================="
echo ""

# Configuration
REPO_DIR="/home/michel/Commercial-Marketplace-SaaS-Accelerator"
RESOURCE_GROUP="rg-saasaccel-teams-gpt-02"
APP_NAME="sac-02-portal"
PUBLISH_DIR="$REPO_DIR/Publish/CustomerSite"
ZIP_FILE="$REPO_DIR/Publish/CustomerSite.zip"

# Vérifier que nous sommes bien dans Cloud Shell
if [ -z "$AZURE_HTTP_USER_AGENT" ]; then
    echo "⚠️  ATTENTION: Ce script doit être exécuté dans Azure Cloud Shell!"
    echo "⚠️  Exécution locale détectée - les binaires seront incompatibles!"
    echo ""
    read -p "Voulez-vous continuer quand même? (yes/no) " -n 3 -r
    echo ""
    if [[ ! $REPLY =~ ^yes$ ]]; then
        echo "Déploiement annulé."
        exit 1
    fi
fi

echo "📁 Étape 1: Mise à jour du code source..."
cd "$REPO_DIR"
git pull origin main
echo "✅ Code source à jour"
echo ""

echo "🔨 Étape 2: Nettoyage des anciennes publications..."
rm -rf "$PUBLISH_DIR"
rm -f "$ZIP_FILE"
echo "✅ Nettoyage effectué"
echo ""

echo "🏗️  Étape 3: Build de CustomerSite (Release)..."
cd "$REPO_DIR/src/CustomerSite"
dotnet publish -c Release -o "$PUBLISH_DIR" --verbosity minimal
echo "✅ Build terminé"
echo ""

echo "📦 Étape 4: Création de l'archive ZIP..."
cd "$REPO_DIR/Publish"
zip -r CustomerSite.zip CustomerSite/ > /dev/null 2>&1
ZIP_SIZE=$(du -h CustomerSite.zip | cut -f1)
echo "✅ Archive créée ($ZIP_SIZE)"
echo ""

echo "🚀 Étape 5: Déploiement vers Azure App Service..."
echo "   Resource Group: $RESOURCE_GROUP"
echo "   App Service: $APP_NAME"
echo ""

az webapp deployment source config-zip \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --src "$ZIP_FILE" \
    --timeout 600

echo ""
echo "✅ Déploiement terminé!"
echo ""

echo "=========================================="
echo "🎯 Prochaines étapes:"
echo "=========================================="
echo "1. Attendre 30 secondes que l'app redémarre"
echo "2. Tester: https://sac-02-portal.azurewebsites.net"
echo "3. Se déconnecter/reconnecter si nécessaire:"
echo "   https://sac-02-portal.azurewebsites.net/Account/SignOut"
echo "4. Vérifier les logs [AUTH-DEBUG] dans Application Insights"
echo ""
echo "Pour voir les logs en temps réel:"
echo "az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"
echo ""
