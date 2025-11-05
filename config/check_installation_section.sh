#!/bin/bash

##############################################################################
# Script de diagnostic - Vérifier si la section Installation est déployée
##############################################################################

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     🔍 DIAGNOSTIC : Section Installation Teams                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PORTAL_URL="https://sac-02-portal.azurewebsites.net"
APP_NAME="sac-02-portal"
RESOURCE_GROUP="rg-saasaccel-teams-gpt-02"

echo "1️⃣  Vérification du dernier commit local"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd /media/psf/Developpement/00-GIT/Commercial-Marketplace-SaaS-Accelerator
CURRENT_COMMIT=$(git rev-parse --short HEAD)
CURRENT_MESSAGE=$(git log -1 --pretty=format:"%s")
echo "✓ Commit actuel : $CURRENT_COMMIT"
echo "✓ Message      : $CURRENT_MESSAGE"
echo ""

echo "2️⃣  Vérification du code dans _LandingPage.cshtml"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if grep -q "Installation de l'application Teams" src/CustomerSite/Views/Home/_LandingPage.cshtml; then
    echo "✓ Section Installation PRÉSENTE dans le code local"
    LINE=$(grep -n "Installation de l'application Teams" src/CustomerSite/Views/Home/_LandingPage.cshtml | head -1 | cut -d: -f1)
    echo "  Ligne $LINE"
else
    echo "✗ Section Installation ABSENTE du code local"
fi
echo ""

echo "3️⃣  Test de la page web pour détecter la section Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Téléchargement de la page..."

TEMP_FILE=$(mktemp)
curl -s -L "$PORTAL_URL" > "$TEMP_FILE"

echo "Analyse du contenu HTML..."
echo ""

if grep -q "Installation de l'application Teams" "$TEMP_FILE"; then
    echo "✅ Section Installation DÉTECTÉE sur le portail"
    echo ""
    echo "   Le code est déployé correctement !"
    echo ""
    echo "   🎯 La section Installation devrait être visible si:"
    echo "      - Vous êtes connecté avec un compte authentifié"
    echo "      - Votre abonnement a le status 'Subscribed'"
    echo ""
else
    echo "❌ Section Installation NON DÉTECTÉE sur le portail"
    echo ""
    echo "   Cela signifie probablement:"
    echo "      1. Le code n'est pas encore déployé sur Azure"
    echo "      2. OU la condition (Status == Subscribed) n'est pas remplie"
    echo "      3. OU vous devez être connecté pour voir cette section"
    echo ""
fi

# Vérifier quelques marqueurs dans le HTML
echo "4️⃣  Analyse du contenu de la page"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "Welcome" "$TEMP_FILE"; then
    echo "✓ Texte 'Welcome' trouvé (page d'accueil standard)"
fi

if grep -q "SaaSKit" "$TEMP_FILE"; then
    echo "✓ Texte 'SaaSKit' trouvé"
fi

if grep -q "Version.*8\.2" "$TEMP_FILE"; then
    echo "✓ Version 8.2.x détectée"
fi

if grep -q "appPackage\.zip" "$TEMP_FILE"; then
    echo "✓ Lien appPackage.zip trouvé"
else
    echo "✗ Lien appPackage.zip non trouvé"
fi

echo ""

rm "$TEMP_FILE"

echo "5️⃣  Vérification du statut de l'abonnement test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Pour vérifier le statut de l'abonnement 'heon-net', exécutez:"
echo ""
echo "az sql db query \\"
echo "  --server sac-02-sql \\"
echo "  --database <database-name> \\"
echo "  --query \"SELECT Name, SubscriptionStatus FROM Subscriptions WHERE Name = 'heon-net'\""
echo ""

echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "📝 PROCHAINES ÉTAPES:"
echo ""
echo "Si la section Installation n'est PAS détectée:"
echo "  → Déployer le code sur Azure avec: bash config/deploy_auth_fix.sh"
echo ""
echo "Si la section Installation EST détectée mais pas visible:"
echo "  → Vérifier le statut de l'abonnement dans la DB"
echo "  → Se connecter au portail et vérifier votre subscription"
echo "  → Consulter les logs: az webapp log tail -n $APP_NAME -g $RESOURCE_GROUP"
echo ""
