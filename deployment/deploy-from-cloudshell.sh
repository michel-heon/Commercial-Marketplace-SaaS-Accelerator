#!/bin/bash
# Script de déploiement pour Azure Cloud Shell
# Usage: ./deploy-from-cloudshell.sh

set -e

echo "================================================"
echo "Déploiement Customer Portal depuis Cloud Shell"
echo "================================================"
echo ""

# Vérifier qu'on est dans Cloud Shell
if [ -z "$AZURE_HTTP_USER_AGENT" ]; then
    echo "⚠️  ATTENTION: Ce script est conçu pour Azure Cloud Shell"
    echo "   Vous pouvez continuer mais assurez-vous d'être authentifié avec Azure CLI"
    echo ""
fi

# Étape 1: Clone ou update du repo
REPO_DIR=~/Commercial-Marketplace-SaaS-Accelerator
if [ -d "$REPO_DIR" ]; then
    echo "📂 Repository existant détecté, mise à jour..."
    cd $REPO_DIR
    git fetch origin
    git reset --hard origin/main
    echo "✅ Repository mis à jour vers origin/main"
else
    echo "📥 Clonage du repository..."
    cd ~
    git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git
    cd $REPO_DIR
    echo "✅ Repository cloné"
fi

echo ""

# Étape 2: Vérifier les derniers commits
echo "📋 Derniers commits:"
git log --oneline -5
echo ""

# Étape 3: Vérifier que la section Installation est présente
if grep -q "Installation de l'application Teams" src/CustomerSite/Views/Home/_LandingPage.cshtml; then
    echo "✅ Section Installation détectée dans _LandingPage.cshtml"
else
    echo "❌ ERREUR: Section Installation NON trouvée!"
    echo "   Vérifiez que le commit c2d6c9d est bien présent"
    exit 1
fi

echo ""

# Étape 4: Lancer le déploiement
echo "🚀 Lancement du déploiement..."
echo "   WebApp: sac-02-portal"
echo "   Resource Group: rg-saasaccel-teams-gpt-02"
echo ""

cd deployment
pwsh ./Upgrade-CustomerPortal.ps1

echo ""
echo "================================================"
echo "✅ Déploiement terminé!"
echo "================================================"
echo ""
echo "🌐 Portail: https://sac-02-portal.azurewebsites.net"
echo ""
echo "Pour vérifier:"
echo "  1. Connectez-vous au portail"
echo "  2. Naviguez vers une souscription avec statut 'Subscribed'"
echo "  3. Vérifiez que la section Installation Teams est visible"
echo ""
