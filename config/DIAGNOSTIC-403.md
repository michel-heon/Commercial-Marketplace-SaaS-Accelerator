# 🚨 Diagnostic Erreur 403 - Customer Portal

**Date**: 5 novembre 2025  
**Erreur**: "You do not have permission to view this directory or page"

---

## 🔍 **Analyse des Logs**

### Symptômes observés:
```
GET / ... 403 14 0 (HTTP 403 Forbidden, sub-status 14)
GET /Home/Index ... 404 0 2 (HTTP 404 Not Found)
GET /favicon.ico ... 404 0 2
```

### Code d'erreur HTTP:
- **403.14** = "Directory listing denied" (IIS)
- **Cause**: L'application .NET n'a jamais démarré

---

## ❌ **Problème Identifié**

### L'application .NET Core est CASSÉE

1. **IIS reçoit la requête** ✅
2. **IIS essaie de démarrer l'application .NET** ❌
3. **L'application crash au démarrage** ❌
4. **IIS renvoie une page d'erreur 403/404** ❌

### Pourquoi?

**Le dernier déploiement (4 nov 13:37 UTC) contenait des binaires ARM64 incompatibles:**
- Build fait depuis Linux ARM64 (Parallels sur Mac)
- Azure App Service: Windows x64
- Erreur runtime: "Could not load file Microsoft.Data.SqlClient"

---

## 🎯 **Solution**

### MUST DO: Redéployer depuis Azure Cloud Shell

Le script `deploy-from-cloudshell.sh` va:
1. Pull le code source mis à jour
2. Builder avec `dotnet publish` (plateforme x64 compatible)
3. Créer une archive ZIP propre
4. Déployer sur Azure App Service

### Commandes dans Azure Cloud Shell (Bash):

```bash
# 1. Se connecter à Azure Portal
# https://portal.azure.com

# 2. Ouvrir Cloud Shell (icône >_ en haut à droite)

# 3. Uploader le script
# Cliquer "Upload/Download files" > Sélectionner deploy-from-cloudshell.sh

# 4. Rendre exécutable et lancer
chmod +x deploy-from-cloudshell.sh
./deploy-from-cloudshell.sh
```

### OU: Commandes manuelles

```bash
cd /home/michel/Commercial-Marketplace-SaaS-Accelerator
git pull origin main
cd src/CustomerSite
dotnet publish -c Release -o ../../Publish/CustomerSite
cd ../../Publish
zip -r CustomerSite.zip CustomerSite/
az webapp deployment source config-zip \
  --resource-group rg-saasaccel-teams-gpt-02 \
  --name sac-02-portal \
  --src CustomerSite.zip \
  --timeout 600
```

---

## 📊 **Logs Détaillés**

### Ce que nous voyons dans les logs IIS:

```
09:28:38 GET /Home/Index ... 404 0 2
         └─ L'application n'existe pas (pas démarrée)

09:28:52 GET / ... 403 14 0
         └─ Directory listing denied (fallback IIS)

Cookie présent: AppServiceAuthSession=FY9Aeo...
         └─ L'authentification fonctionne
         └─ Mais l'app ne répond pas
```

### Ce que nous DEVRIONS voir après le fix:

```
GET / ... 200 0 0
GET /Home/Index ... 200 0 0
[AUTH-DEBUG] User.Identity.IsAuthenticated: True
[AUTH-DEBUG] CurrentUserEmailAddress: ...
```

---

## ⏱️ **Timeline du Problème**

| Date/Heure (UTC) | Action | Résultat |
|------------------|--------|----------|
| 4 nov 11:14 | Déploiement Cloud Shell 1 | ✅ OK (sans @model) |
| 4 nov 11:46 | Déploiement Cloud Shell 2 | ✅ OK (avec @model) |
| 4 nov 13:37 | **Déploiement LOCAL ARM64** | ❌ **CASSÉ** |
| 5 nov 09:28 | Tests utilisateur | ❌ Erreur 403 |
| 5 nov 09:29 | Consultation logs | 🔍 Diagnostic |

---

## 🚀 **Après le Redéploiement**

### Tests à effectuer:

1. **Logout complet**:
   ```
   https://sac-02-portal.azurewebsites.net/Account/SignOut
   ```

2. **Effacer cookies navigateur** (F12 > Application > Clear storage)

3. **Accéder au portal**:
   ```
   https://sac-02-portal.azurewebsites.net
   ```

4. **Vérifier**:
   - ✅ Redirection vers Microsoft login
   - ✅ Authentification réussie
   - ✅ Page Subscriptions visible
   - ✅ Cliquer sur "heon-net" → Landing Page s'affiche
   - ✅ Encadré DEBUG jaune visible (temporaire)
   - ✅ Section Installation Teams visible (si status = Subscribed)

---

## 📝 **Logs de Debug Ajoutés**

### Dans le code (pas encore déployé):

**HomeController.cs**:
- `[AUTH-DEBUG] User.Identity.IsAuthenticated`
- `[AUTH-DEBUG] CurrentUserEmailAddress`
- `[AUTH-DEBUG] SubscriptionStatus`

**Index.cshtml**:
- `[INDEX-VIEW-DEBUG] Model is null`
- `[INDEX-VIEW-DEBUG] Model.SubscriptionStatus`

Ces logs seront visibles dans Application Insights après le redéploiement.

---

## 🔗 **Ressources**

- **Portal URL**: https://sac-02-portal.azurewebsites.net
- **Logout URL**: https://sac-02-portal.azurewebsites.net/Account/SignOut
- **Resource Group**: rg-saasaccel-teams-gpt-02
- **App Service**: sac-02-portal

**Script de déploiement**: `config/deploy-from-cloudshell.sh`  
**Audit complet**: `config/AUDIT-LANDING-PAGE.md`
