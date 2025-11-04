# Configuration et Déploiement

Ce dossier contient les outils et configurations pour déployer le SaaS Accelerator.

## 🚀 Installation rapide

### Linux / macOS / Azure Cloud Shell

```bash
# 1. Installer Make (si nécessaire)
# Linux (Ubuntu/Debian):
sudo apt-get install make

# macOS:
brew install make

# Azure Cloud Shell: déjà installé ✓

# 2. Voir les commandes disponibles
make help

# 3. Setup complet (installe .NET + vérifie Azure CLI)
make setup

# 4. Déployer Customer Portal
make deploy-customer
```

### Windows PowerShell

```powershell
# 1. Installer Make (nécessite droits administrateur)
.\install-make.ps1

# 2. Redémarrer PowerShell

# 3. Voir les commandes disponibles
make help

# 4. Setup complet
make setup

# 5. Déployer Customer Portal
make deploy-customer
```

## 📋 Commandes disponibles

| Commande | Description |
|----------|-------------|
| `make help` | Affiche l'aide |
| `make install-dotnet` | Installe .NET SDK 8.0.303 et EF Core tools |
| `make check-dotnet` | Vérifie que .NET est installé |
| `make check-azure` | Vérifie Azure CLI et connexion |
| `make setup` | Setup complet (dotnet + azure) |
| `make build-customer` | Build Customer Portal |
| `make build-admin` | Build Admin Portal |
| `make package-customer` | Package Customer Portal en ZIP |
| `make package-admin` | Package Admin Portal en ZIP |
| `make deploy-customer` | Déploie Customer Portal vers Azure |
| `make deploy-admin` | Déploie Admin Portal vers Azure |
| `make deploy-all` | Déploie les deux portails |
| `make quick-deploy` | Build + déploie Customer Portal (dev) |
| `make clean` | Nettoie les artefacts de build |
| `make info` | Affiche la configuration de déploiement |

## ⚙️ Configuration

Éditez `Makefile.vars` pour modifier la configuration:

```makefile
# Azure Resource Configuration
RESOURCE_GROUP=rg-saasaccel-teams-gpt-02
WEBAPP_PREFIX=sac-02
LOCATION=Canada Central

# .NET Configuration
DOTNET_VERSION=8.0.303
DOTNET_EF_VERSION=8.0.6
```

## 🔧 Workflow de développement

### Développement rapide

```bash
# Modifier le code
# ...

# Déployer rapidement
make quick-deploy

# Vérifier
make info
```

### Déploiement complet

```bash
# Build tout
make build-customer
make build-admin

# Déployer tout
make deploy-all
```

### Nettoyage

```bash
# Supprimer les artefacts de build
make clean
```

## 🐛 Troubleshooting

### .NET SDK non trouvé

```bash
make install-dotnet
```

### Azure CLI non connecté

```bash
make check-azure
# Suivre les instructions pour se connecter
```

### Make non trouvé (Windows)

```powershell
# Exécuter en tant qu'administrateur
.\install-make.ps1
```

### Erreur de build

```bash
# Nettoyer et rebuild
make clean
make build-customer
```

## 📁 Structure

```
config/
├── Makefile              # Commandes de build/déploiement
├── Makefile.vars         # Variables de configuration
├── install-make.ps1      # Script d'installation Make (Windows)
├── # Configuration et Déploiement - Makefile

Ce dossier contient les outils de déploiement simplifiés pour le Commercial Marketplace SaaS Accelerator.

## 🚀 Quick Start

```bash
# Dans Azure Cloud Shell ou votre terminal
cd Commercial-Marketplace-SaaS-Accelerator/config

# Voir toutes les commandes disponibles
make help

# Setup initial (une seule fois)
make setup

# Déploiement complet (recommandé)
make full-deploy
```

## 📁 Fichiers

- **Makefile** - Commandes de déploiement automatisées
- **Makefile.vars** - Configuration des variables (à personnaliser)
- **configuration.md** - Documentation complète
- **deploy_customer_portal.sh** - Script shell alternatif
- **install-make.ps1** - Installation de Make sur Windows

## ⚙️ Configuration

Éditez `Makefile.vars` pour personnaliser votre déploiement :

```makefile
# Azure Resource Configuration
RESOURCE_GROUP=rg-saasaccel-teams-gpt-02
WEBAPP_PREFIX=sac-02
LOCATION=Canada Central

# Azure Resources Names
ADMIN_WEBAPP=$(WEBAPP_PREFIX)-admin
CUSTOMER_WEBAPP=$(WEBAPP_PREFIX)-portal
SQL_SERVER=$(WEBAPP_PREFIX)-sql
KEY_VAULT=$(WEBAPP_PREFIX)-kv
```

## 📋 Commandes Principales

### Setup

```bash
make setup              # Installation complète (dotnet + azure cli check)
make install-dotnet     # Installer .NET SDK uniquement
make check-azure        # Vérifier Azure CLI
make info               # Afficher la configuration
```

### Déploiement

```bash
make full-deploy        # 🔥 Workflow complet (git + build + deploy)
make deploy-customer    # Déployer le portail client uniquement
make deploy-admin       # Déployer le portail admin uniquement
make deploy-all         # Déployer les deux portails
```

### Maintenance

```bash
make restart-customer   # Redémarrer le portail client
make logs-customer      # Voir les logs en temps réel
make browse-customer    # Ouvrir dans le navigateur
make clean              # Nettoyer les artefacts de build
```

### Git

```bash
make git-status         # Voir le statut du repository
make git-pull           # Récupérer les dernières modifications
make update-and-deploy  # Pull + deploy
```

## 🎯 Workflow Typique

### Première Installation

```bash
# 1. Cloner le repository
git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git
cd Commercial-Marketplace-SaaS-Accelerator/config

# 2. Personnaliser la configuration (optionnel)
vi Makefile.vars

# 3. Setup
make setup

# 4. Déployer
make full-deploy
```

### Mise à Jour Quotidienne

```bash
cd Commercial-Marketplace-SaaS-Accelerator/config
make full-deploy
```

### Débogage

```bash
# Voir les logs
make logs-customer

# Redémarrer l'application
make restart-customer

# Ouvrir dans le navigateur
make browse-customer
```

## 🔧 Dépannage

### Make non installé

**Sur Azure Cloud Shell** : Make est déjà installé

**Sur Windows PowerShell** :

```powershell
.\install-make.ps1
```

### Erreur "dotnet not found"

```bash
make install-dotnet
```

### Erreur "not logged into Azure"

```bash
az login
make check-azure
```

### Erreur de déploiement

```bash
# Vérifier les logs
make logs-customer

# Nettoyer et redéployer
make clean
make full-deploy
```

## 📊 Structure du Build

```
Commercial-Marketplace-SaaS-Accelerator/
├── src/
│   ├── CustomerSite/        # Code source portail client
│   └── AdminSite/           # Code source portail admin
├── Publish/
│   ├── CustomerSite/        # Build compilé (client)
│   ├── AdminSite/           # Build compilé (admin)
│   ├── CustomerSite.zip     # Package de déploiement
│   └── AdminSite.zip        # Package de déploiement
└── config/
    ├── Makefile             # Ce fichier
    └── Makefile.vars        # Configuration
```

## 🌐 URLs de Déploiement

Après un déploiement réussi :

- **Portail Client** : https://sac-02-portal.azurewebsites.net
- **Portail Admin** : https://sac-02-admin.azurewebsites.net

## 📚 Documentation Complète

Voir [configuration.md](./configuration.md) pour :

- Guide complet de déploiement
- Configuration PartnerCenter
- Troubleshooting détaillé
- Méthodes manuelles alternatives

## 🎨 Couleurs dans l'Output

Le Makefile utilise des couleurs pour améliorer la lisibilité :

- 🔵 **Bleu (Info)** : Messages d'information
- 🟢 **Vert (Success)** : Opérations réussies
- 🟡 **Jaune (Warning)** : Avertissements
- 🔴 **Rouge (Error)** : Erreurs

## 🤝 Support

Pour toute question ou problème :

1. Consulter [configuration.md](./configuration.md)
2. Consulter [../docs/FAQs.md](../docs/FAQs.md)
3. Ouvrir une issue sur GitHub

## 📝 License

Voir [../LICENSE](../LICENSE)
             # Cette documentation
├── configuration.md      # Configuration Azure (legacy)
└── deploy_customer_portal.sh  # Script de déploiement direct (legacy)
```

## 🔐 Prérequis

- **Azure CLI** installé et connecté (`az login`)
- **Make** installé (voir instructions ci-dessus)
- **Accès** au resource group Azure configuré
- **.NET SDK 8.0.303** (installé automatiquement par `make install-dotnet`)

## 💡 Conseils

1. **Utilisez toujours Azure Cloud Shell** pour les déploiements de production (compatibilité garantie)
2. **`make quick-deploy`** est parfait pour le développement rapide
3. **`make info`** affiche toutes les URLs importantes
4. **`make help`** si vous oubliez une commande

## 🌐 URLs importantes

- Customer Portal: https://sac-02-portal.azurewebsites.net
- Admin Portal: https://sac-02-admin.azurewebsites.net
- SQL Server: sac-02-sql.database.windows.net
- Key Vault: https://sac-02-kv.vault.azure.net
