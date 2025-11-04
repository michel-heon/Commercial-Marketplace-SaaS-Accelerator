# Configuration et Déploiement - Commercial Marketplace SaaS Accelerator

## 🚀 Déploiement Rapide avec Makefile (Recommandé)

### Prérequis
- Azure Cloud Shell (PowerShell) ou terminal Linux/macOS avec Azure CLI installé
- Accès au repository Git

### Installation initiale (une seule fois)

```bash
# 1. Cloner le repository
git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git --depth 1
cd Commercial-Marketplace-SaaS-Accelerator/config

# 2. Configurer les variables (éditer Makefile.vars si nécessaire)
# Les valeurs par défaut sont déjà configurées pour sac-02

# 3. Installer les dépendances
make setup
```

### Déploiement complet (mise à jour + build + déploiement)

```bash
cd Commercial-Marketplace-SaaS-Accelerator/config
make full-deploy
```

### Commandes disponibles

#### 🔧 Setup et Configuration
- `make help` - Afficher toutes les commandes disponibles
- `make setup` - Installer .NET SDK et vérifier Azure CLI
- `make info` - Afficher la configuration du déploiement
- `make check-azure` - Vérifier la connexion Azure

#### 📦 Build et Package
- `make build-customer` - Compiler le portail client
- `make build-admin` - Compiler le portail admin
- `make package-customer` - Créer le package ZIP du portail client
- `make package-admin` - Créer le package ZIP du portail admin

#### 🚀 Déploiement
- `make deploy-customer` - Déployer le portail client
- `make deploy-admin` - Déployer le portail admin
- `make deploy-all` - Déployer les deux portails
- `make full-deploy` - **Workflow complet** (git pull + build + deploy client)
- `make quick-deploy` - Déploiement rapide du portail client

#### 🔄 Git
- `make git-status` - Voir le statut du repository
- `make git-pull` - Récupérer les dernières modifications
- `make update-and-deploy` - Mettre à jour et déployer

#### 🔨 Maintenance
- `make restart-customer` - Redémarrer le portail client
- `make restart-admin` - Redémarrer le portail admin
- `make logs-customer` - Voir les logs en temps réel (client)
- `make logs-admin` - Voir les logs en temps réel (admin)
- `make browse-customer` - Ouvrir le portail client dans le navigateur
- `make browse-admin` - Ouvrir le portail admin dans le navigateur
- `make clean` - Nettoyer les artefacts de build

### Exemple d'utilisation typique

```bash
# Mise à jour quotidienne après modifications Git
cd Commercial-Marketplace-SaaS-Accelerator/config
make full-deploy

# Redémarrer l'application après modification de configuration
make restart-customer

# Voir les logs en temps réel
make logs-customer
```

---

## 📋 Méthode Manuelle (Alternative)

### Installation des prérequis

```bash
wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh -version 8.0.303
export PATH="$HOME/.dotnet:$PATH"
dotnet tool install --global dotnet-ef --version 8.0.6
```

### Cloner et déployer

```bash
git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git --depth 1
cd Commercial-Marketplace-SaaS-Accelerator/config
```

### Mise à jour et déploiement manuel

```bash
# 1. Récupérer les dernières modifications
cd Commercial-Marketplace-SaaS-Accelerator
git pull origin main

# 2. Compiler le projet
cd src/CustomerSite
dotnet build --configuration Release

# 3. Publier l'application
dotnet publish --configuration Release --output ../../Publish/CustomerSite

# 4. Créer le package
cd ../../Publish/CustomerSite
zip -r ../CustomerSite.zip .

# 5. Déployer sur Azure
az webapp deploy \
  --resource-group rg-saasaccel-teams-gpt-02 \
  --name sac-02-portal \
  --src-path ../CustomerSite.zip \
  --type zip
```

## 📝 Configuration PartnerCenter (Après déploiement)

Une fois le déploiement terminé avec succès :

### Informations à configurer dans PartnerCenter

**SaaS Technical Configuration**

- **Landing Page** : `https://sac-02-portal.azurewebsites.net/`
- **Connection Webhook** : `https://sac-02-portal.azurewebsites.net/api/AzureWebhook`
- **Tenant ID** : `aba0984a-85a2-4fd4-9ae5-0a45d7efc9d2`
- **AAD Application ID** : `d3b2710f-1be9-4f89-8834-6273619bd838`

### Configuration Azure AD Authentication

L'authentification Azure App Service est configurée avec :

- **Enabled** : `true`
- **Provider** : `AzureActiveDirectory`
- **Client ID** : `9eecb51f-1b92-4227-8a48-924fb946e118` (MTClientId)
- **Redirect URI** : `https://sac-02-portal.azurewebsites.net/.auth/login/aad/callback`
- **Unauthenticated Action** : `RedirectToLoginPage`

## 🔧 Corrections Appliquées

### Problèmes Résolus

1. **Conflit d'authentification** : Le `BaseController.CheckAuthentication()` a été désactivé car App Service Auth gère l'authentification
2. **Redirect URI manquante** : Ajout de `/.auth/login/aad/callback` dans l'App Registration
3. **Double redirection** : Suppression de la logique de redirection redondante dans `HomeController`

### Fichiers Modifiés

- `src/CustomerSite/Controllers/BaseController.cs` - Désactivé CheckAuthentication() dans le constructeur
- `src/CustomerSite/Controllers/HomeController.cs` - Supprimé la vérification d'authentification redondante

## 🐛 Troubleshooting

### Erreur "You do not have permission to view this directory or page"

Cette erreur a été résolue en :

1. Activant Azure App Service Authentication
2. Ajoutant la Redirect URI correcte
3. Supprimant les conflits d'authentification dans le code

### Erreur de connexion SQL lors du déploiement initial

Si vous rencontrez une erreur de connexion SQL, vérifiez :

- Le firewall du SQL Server autorise votre IP
- L'authentification Azure AD est configurée
- La connexion réseau est stable

## 📚 Ressources

- [Documentation officielle SaaS Accelerator](https://github.com/Azure/Commercial-Marketplace-SaaS-Accelerator)
- [Guide d'installation](../docs/Installation-Instructions.md)
- [FAQ](../docs/FAQs.md)
