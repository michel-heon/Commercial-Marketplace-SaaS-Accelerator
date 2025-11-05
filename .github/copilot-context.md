# Context de Projet pour GitHub Copilot

> **Document de référence** : À lire par GitHub Copilot au démarrage d'une nouvelle session VS Code
> **Dernière mise à jour** : 2025-11-05
> **Projet** : Teams GPT SaaS - Intégration Commercial Marketplace + Microsoft Teams

---

## 🎯 Vue d'Ensemble du Projet

Ce projet intègre le **Commercial Marketplace SaaS Accelerator** de Microsoft avec une application **Microsoft Teams (bot GPT)** pour créer une solution SaaS distribuée via l'Azure Marketplace.

### Architecture Globale

```
Azure Marketplace (Achat)
    ↓
SaaS Fulfillment API (Activation webhook)
    ↓
Customer Portal (sac-02-portal.azurewebsites.net)
    ↓
Teams Bot (teams-gpt-xxxxx.azurewebsites.net)
    ↓
Azure SQL Database (Usage tracking)
```

---

## 📁 Structure des Répertoires

### Répertoire Principal
**Path** : `/media/psf/Developpement/00-GIT/Commercial-Marketplace-SaaS-Accelerator`

C'est le répertoire de travail principal qui contient :

```
Commercial-Marketplace-SaaS-Accelerator/
├── src/
│   ├── CustomerSite/              # Customer Portal (ASP.NET Core MVC)
│   │   ├── Controllers/
│   │   │   └── HomeController.cs  # ⚠️ MODIFIÉ - Logging ajouté
│   │   ├── Views/Home/
│   │   │   └── _LandingPage.cshtml # ⚠️ MODIFIÉ - Section Installation Teams
│   │   └── wwwroot/
│   ├── AdminSite/                 # Admin Portal
│   └── WebHook/                   # Marketplace webhook handler
│
├── deployment/                     # Scripts de déploiement Azure
├── docs/                          # Documentation (pas encore créée)
└── .github/
    └── copilot-context.md         # 👈 CE FICHIER

Repository lié (appPackage Teams uniquement) :
michel-heon/teams-gpt-saas-acc
└── appPackage/
    ├── manifest.json              # Manifest Teams App
    ├── color.png                  # Icône 192×192
    └── outline.png                # Icône 32×32
```

---

## 🔧 État Actuel du Projet (2025-11-05)

### Phase en Cours : **Phase 2.3 - Intégration Customer Portal ↔ Teams**

#### ✅ Travaux Complétés

1. **Infrastructure SaaS Accelerator**
   - Déployée sur Azure : `sac-02-portal` (Customer Portal)
   - Base de données : Azure SQL Database
   - Webhook configuré pour Partner Center
   - Plan test : `dev-01` (offre `teams-gpt-preview`)

2. **Application Teams**
   - Manifest finalisé (`appPackage/manifest.json`)
   - Icônes conformes Microsoft Teams Store
   - Package distribué via GitHub releases
   - Documentation installation : `INSTALLATION.md` (v1.3.1)

3. **Customer Portal - Modifications**
   - ✅ **Commit c2d6c9d** : Section "Installation de l'application Teams" ajoutée
   - ✅ **Commit be2adbe** : Corrections erreurs compilation Razor
   - ✅ **Commit 8458cc3** : Logging ajouté dans `HomeController.cs`

#### ⚠️ Problème Actuel (CRITIQUE)

**Symptôme** : Section "Installation" pas visible après déploiement  
**Cause identifiée** : Le code déployé sur Azure ne correspond pas aux derniers commits

**Evidence** :
- Logs Azure : AUCUN log applicatif visible (lignes `[HOME-INDEX-START]`, etc.)
- Abonnement `heon-net` : Status = `Subscribed` ✅
- Page d'accueil : Affiche seulement "Welcome" (ancien code)
- Attendu : Section "Installation de l'application Teams" si status = Subscribed

**Commits non déployés** :
```
be2adbe - fix: Add missing closing brace (Phase 29)
8458cc3 - Add comprehensive logging to HomeController.Index() (Phase 29)
c2d6c9d - feat: Ajout section Installation dans _LandingPage.cshtml (Phase 22)
```

#### 🚧 Actions Requises (TODO)

1. **URGENT : Vérifier et redéployer le code**
   - Vérifier quel commit est actuellement déployé sur Azure
   - Forcer le déploiement du dernier code (commit be2adbe)
   - Vérifier que les logs applicatifs apparaissent

2. **Tester le parcours client complet**
   - Connexion au portail avec `heon@cotechnoe.net`
   - Vérifier visibilité section Installation
   - Télécharger `appPackage.zip`
   - Installer dans Teams
   - Vérifier tracking usage en DB

---

## 🔑 Fichiers Clés Modifiés

### 1. `src/CustomerSite/Views/Home/_LandingPage.cshtml`

**Lignes ~197-250** : Section Installation conditionnelle

```cshtml
@{
    var dbg_IsSubscribed = Model.SubscriptionStatus == SubscriptionStatusEnumExtension.Subscribed;
    System.Diagnostics.Debug.WriteLine($"[INSTALLATION-CHECK] Status={Model.SubscriptionStatus}, WillRender={dbg_IsSubscribed}");
}

@if (Model.SubscriptionStatus == SubscriptionStatusEnumExtension.Subscribed)
{
    <div class="text-white mt-4">
        <span class="cm-section-heading">Installation de l'application Teams</span>
    </div>
    <div class="cm-description-text" style="margin-top: 1.5rem;">
        Merci pour votre abonnement! Vous pouvez maintenant installer l'application Teams GPT...
    </div>
    <div class="mt-3">
        <a class="download-manifest-button" href="@Url.Action("DownloadManifest", "Home")">
            <i class="ms-Icon ms-Icon--Download" aria-hidden="true"></i>
            Télécharger le fichier manifest.zip
        </a>
    </div>
    <!-- Liens vers INSTALLATION.md et SUPPORT.md -->
}
```

**Condition d'affichage** : `Model.SubscriptionStatus == SubscriptionStatusEnumExtension.Subscribed`

### 2. `src/CustomerSite/Controllers/HomeController.cs`

**Lignes 215-308** : Logging diagnostic ajouté

```csharp
public async Task<IActionResult> Index(string token = null)
{
    // Line 215 - Log d'entrée
    this.logger.Info($"[HOME-INDEX-START] Token present: {!string.IsNullOrEmpty(token)}, User authenticated: {this.User.Identity.IsAuthenticated}");
    
    // Line 216 - Log utilisateur
    this.logger.Info($"[HOME-INDEX-START] User email: {this.CurrentUserEmailAddress}");
    
    // ... construction du modèle ...
    
    // Line 285 - Log de sortie avec état du modèle
    this.logger.Info($"[HOME-INDEX-END] Returning Model. ShowWelcomeScreen = {subscriptionExtension.ShowWelcomeScreen}, SubscriptionStatus = {subscriptionExtension.SubscriptionStatus}");
    
    return this.View(subscriptionExtension);
}
```

**Type de logger** : `SaaSClientLogger<HomeController>` (custom logger)  
**Problème connu** : Les logs n'apparaissent pas dans Azure App Service filesystem logs  
**Hypothèse** : Le logger custom écrit uniquement dans Application Insights

---

## 🗄️ Base de Données Azure SQL

### Tables Clés

1. **`Subscriptions`**
   - Stocke les abonnements marketplace
   - Champ important : `SubscriptionStatus` (valeurs : PendingFulfillmentStart, Subscribed, Unsubscribed)
   - Abonnement test actuel : `heon-net` (Status = Subscribed depuis 2025-11-03 10:35)

2. **`MeteredAuditLogs`**
   - Track l'usage du bot Teams (messages envoyés)
   - Agrégation horaire pour facturation Azure Marketplace
   - Colonnes : `SubscriptionId`, `RequestJson`, `StatusCode`, `CreatedDate`

3. **`ApplicationLog`**
   - Logs applicatifs (peut contenir les logs du custom logger)
   - À vérifier si les logs HomeController y sont stockés

---

## 🚀 Déploiement Azure

### Ressources Déployées

**Resource Group** : `rg-saasaccel-teams-gpt-02`  
**Région** : Canada Central

**Services** :
- `sac-02-portal` - App Service (Customer Portal) - ASP.NET Core 8.0
- `sac-02-admin` - App Service (Admin Portal)
- `sac-02-webhook` - App Service (Marketplace webhook)
- Azure SQL Database
- Application Insights : `sac-02-portal` (logs APM)

### Configuration Logging Azure

**État actuel** (configuré le 2025-11-05 15:46 UTC) :
```json
{
  "applicationLogs": {
    "fileSystem": {
      "level": "Information"  // ✅ ACTIVÉ
    }
  },
  "httpLogs": {
    "fileSystem": {
      "enabled": true,
      "retentionInDays": 3
    }
  }
}
```

**Commande pour voir les logs** :
```bash
az webapp log tail --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02
```

---

## 📝 Historique Git - Commits Importants

### Repository Principal (Commercial-Marketplace-SaaS-Accelerator)

```
be2adbe (2025-11-05) - fix: Add missing closing brace for @if block (RZ1010)
90911f8 (2025-11-05) - fix: Resolve RZ1010, CS0023, CS0128 compilation errors
8458cc3 (2025-11-05) - Add comprehensive logging to HomeController.Index()
c2d6c9d (2025-11-04) - feat: Ajout section Installation dans Customer Portal
314a9b4 (2025-11-03) - Initial integration Customer Portal + Teams
```

### Repository AppPackage (teams-gpt-saas-acc)

```
38ddce2 (2025-11-05) - feat(icons): Redesign logo - modern circular style
8bc607b (2025-11-05) - chore: Ajout fichier référence distribution
```

**⚠️ IMPORTANT** : Les modifications du Customer Portal sont dans le repository `Commercial-Marketplace-SaaS-Accelerator`, PAS dans `teams-gpt-saas-acc` !

---

## 🧪 Tests et Validation

### Abonnement de Test

**Utilisateur** : `heon@cotechnoe.net` (Michel Héon)  
**Subscription ID** : `b8c115c2-fec3-4b75-ddd9-39ff53febb38`  
**Plan** : `dev-01`  
**Offre** : `teams-gpt-preview`  
**Status** : `Subscribed` (depuis 2025-11-03 10:35)

### Parcours de Test à Valider

1. ✅ Achat Azure Marketplace → webhook → activation
2. ❌ **Portail client affiche section Installation** (BLOQUÉ - code non déployé)
3. ⏸️ Téléchargement `appPackage.zip`
4. ⏸️ Installation dans Teams (chargement latéral ou Admin Center)
5. ⏸️ Premier message au bot
6. ⏸️ Vérification `TeamsUserId` en DB
7. ⏸️ Vérification `MeteredAuditLogs` (agrégation horaire)

---

## 🔍 Diagnostic - Problème Actuel

### Symptômes Observés (2025-11-05 15:52 UTC)

**Logs HTTP Azure** (extrait) :
```
15:52:43 GET /Home/Index/ → 200 OK (5455 bytes)
15:52:54 POST /Home/Index → 302 redirect (auth flow)
15:52:54 GET / → 200 OK (5452 bytes)  # ← HomeController.Index() exécuté
15:53:23 GET /Home/Subscriptions → 200 OK (6675 bytes)
```

**Logs applicatifs attendus** (ABSENTS) :
```
[HOME-INDEX-START] Token present: true, User authenticated: true
[HOME-INDEX-START] User email: heon@cotechnoe.net
[HOME-INDEX-END] Returning Model. ShowWelcomeScreen = false, SubscriptionStatus = Subscribed
```

**Evidence** :
- ✅ Utilisateur authentifié avec succès (cookie `.AspNetCore.Cookies` présent)
- ✅ Page `/Home/Index` retourne 200 OK avec taille correcte (~5450 bytes)
- ✅ Utilisateur peut naviguer (Subscriptions accessible)
- ❌ Aucun log applicatif dans le stream
- ❌ Section Installation pas visible (screenshot fourni)

### Hypothèses

1. **Code non déployé** (PLUS PROBABLE)
   - Le déploiement Azure n'a pas été fait après commit be2adbe
   - Azure sert encore l'ancien code (commit 314a9b4 ou antérieur)
   - Solution : Redéployer depuis Azure Cloud Shell

2. **Custom Logger non configuré**
   - `SaaSClientLogger<T>` écrit uniquement dans Application Insights
   - Pas dans filesystem logs
   - Solution : Vérifier Application Insights avec requête KQL

3. **Cache Azure**
   - App Service cache l'ancienne version
   - Solution : Restart App Service

---

## 📋 Todo List Copilot (À Régénérer)

### ✅ Complétés (Phase 1 & 2.1)

- [x] Infrastructure et SaaS Accelerator
- [x] Finaliser manifest Teams (appPackage/manifest.json)
- [x] Créer package Teams (appPackage.zip)
- [x] Configuration Partner Center
- [x] Guide installation IT admin (INSTALLATION.md v1.3.1)
- [x] Intégrer instructions dans Customer Portal (commit c2d6c9d)

### 🚧 En Cours (Phase 2.3)

- [ ] **URGENT : Déployer le code corrigé**
  - Vérifier commit déployé sur Azure (`sac-02-portal`)
  - Redéployer depuis commit be2adbe
  - Valider que logs applicatifs apparaissent
  - Confirmer section Installation visible

### ⏸️ En Attente (Phase 3)

- [ ] **Tester parcours complet client (plan dev-01)**
  - Simuler : achat → activation → portail (section Installation visible)
  - Télécharger appPackage.zip
  - Installer dans Teams (chargement latéral ou Admin Center)
  - Envoyer premier message bot
  - Vérifier TeamsUserId en DB
  - Valider MeteredAuditLogs (agrégation horaire)

- [ ] **Créer assets visuels**
  - Capturer 5-10 screenshots annotés (installation, usage, analyse document)
  - Enregistrer 2 vidéos (installation 2-3 min, usage 2-3 min)
  - Format : 1280×720 ou 1920×1080
  - Intégrer dans distribution GitHub

- [ ] **Documenter configuration env production**
  - Créer guide migration Playground → Production
  - Variables environnement
  - Managed Identity (Azure SQL, Key Vault)
  - Bot Framework endpoints
  - App Service config
  - Sécurité (HTTPS, auth, secrets)
  - Conformité GDPR

- [ ] **Valider conformité Microsoft Teams Store**
  - Vérifier manifest.json contre guidelines
  - Tester validation Partner Center
  - Vérifier icons (déjà conforme)
  - Préparer screenshots/vidéos
  - Documenter non-conformités et corrections
  - Soumission finale

---

## 🛠️ Commandes Utiles

### Git

```bash
# Vérifier l'état actuel
cd /media/psf/Developpement/00-GIT/Commercial-Marketplace-SaaS-Accelerator
git status
git log --oneline -10

# Vérifier les modifications non commitées
git diff

# Voir les commits récents sur Customer Portal
git log --oneline --follow -- src/CustomerSite/Views/Home/_LandingPage.cshtml
git log --oneline --follow -- src/CustomerSite/Controllers/HomeController.cs
```

### Azure Logging

```bash
# Activer application logging (déjà fait)
az webapp log config --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02 \
  --application-logging filesystem --level information

# Stream des logs en temps réel
az webapp log tail --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02

# Filtrer les logs pour trouver nos messages
az webapp log tail --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02 2>&1 | \
  grep -E "(HOME-INDEX|LANDING-PAGE|INSTALLATION-CHECK)"

# Télécharger tous les logs
az webapp log download --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02 \
  --log-file logs.zip
```

### Azure App Service

```bash
# Vérifier le commit déployé
az webapp deployment source show \
  --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02

# Redémarrer l'App Service (clear cache)
az webapp restart \
  --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02

# Forcer un redéploiement
az webapp deployment source sync \
  --name sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02
```

### Application Insights (Alternative aux logs filesystem)

```bash
# Requête KQL pour logs HomeController
az monitor app-insights query \
  --app sac-02-portal \
  --resource-group rg-saasaccel-teams-gpt-02 \
  --analytics-query "traces | where timestamp > ago(1h) | where message contains 'HOME-INDEX' | project timestamp, message, severityLevel"
```

---

## 🔗 Références et Documentation

### Documentation Projet

- **Architecture SaaS Marketplace** : `doc/architecture/saas-marketplace-architecture.md`
- **Phase 2 - Teams Integration** : `doc/architecture/phase2-teams-integration.md`
- **Installation Guide** : `INSTALLATION.md` (repository teams-gpt-saas-acc)
- **Plan Phase 2.3** : `doc/architecture/PHASE-2.3-PLAN.md`

### Documentation Microsoft

- [Commercial Marketplace SaaS Accelerator](https://github.com/Azure/Commercial-Marketplace-SaaS-Accelerator)
- [SaaS Fulfillment API v2](https://docs.microsoft.com/azure/marketplace/partner-center-portal/pc-saas-fulfillment-api-v2)
- [Microsoft Teams App Manifest](https://docs.microsoft.com/microsoftteams/platform/resources/schema/manifest-schema)
- [Azure Marketplace Metered Billing](https://docs.microsoft.com/azure/marketplace/partner-center-portal/saas-metered-billing)

### URLs Production

- **Customer Portal** : https://sac-02-portal.azurewebsites.net
- **Admin Portal** : https://sac-02-admin.azurewebsites.net
- **Webhook** : https://sac-02-webhook.azurewebsites.net
- **GitHub Release** : https://github.com/michel-heon/teams-gpt-saas-acc/releases

---

## 🎯 Objectifs de Session

Quand vous (GitHub Copilot) commencez une nouvelle session :

1. **Lire ce fichier** pour comprendre le contexte complet
2. **Régénérer la todo list** avec l'état actuel
3. **Identifier le problème bloquant** (actuellement : code non déployé)
4. **Proposer les prochaines actions** basées sur les priorités
5. **Fournir les commandes exactes** pour débloquer la situation

### Questions à Poser au Développeur

1. "As-tu accès à Azure Cloud Shell pour vérifier le déploiement ?"
2. "Peux-tu exécuter `az webapp deployment source show` pour voir quel commit est déployé ?"
3. "Veux-tu que je t'aide à créer un script de déploiement automatisé ?"
4. "Dois-je vérifier Application Insights pour les logs au lieu de filesystem ?"

---

## 📌 Notes Importantes

### ⚠️ Points d'Attention

1. **Deux Repositories** :
   - `/Commercial-Marketplace-SaaS-Accelerator` → Code backend (C# ASP.NET Core)
   - `/teams-gpt-saas-acc` → Code Teams app (manifest, icons, docs)

2. **Logging Custom** :
   - Le logger `SaaSClientLogger<T>` ne fonctionne peut-être pas avec filesystem logs
   - Privilégier Application Insights pour les logs applicatifs
   - Alternative : Ajouter `Console.WriteLine()` pour debugging

3. **Section Installation** :
   - Condition : `SubscriptionStatus == Subscribed`
   - L'abonnement test `heon-net` est bien `Subscribed` ✅
   - Le problème est côté code déployé, pas côté données

4. **Déploiement Azure** :
   - Le déploiement peut prendre 5-10 minutes
   - Toujours vérifier les logs de déploiement
   - Un restart de l'App Service peut être nécessaire

### 🎓 Leçons Apprises

1. **Always verify deployment** : Le code committé ≠ code déployé
2. **Custom loggers need verification** : Tester où ils écrivent réellement
3. **Application Insights over filesystem** : Pour les logs applicatifs ASP.NET Core
4. **Always add entry/exit logs** : Pour tracer l'exécution des controllers

---

**Fin du document de contexte**

*Généré le : 2025-11-05*  
*Auteur : Michel Héon (avec assistance GitHub Copilot)*  
*Version : 1.0*
