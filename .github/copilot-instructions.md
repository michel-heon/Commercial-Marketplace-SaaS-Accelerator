# Instructions GitHub Copilot - Commercial Marketplace SaaS Accelerator

> **Document de référence pour Copilot** : Instructions de travail pour ce repository
> **Dernière mise à jour** : 2025-11-05
> **Projet** : Teams GPT SaaS - Backend Customer Portal

---

## 🎯 Contexte du Projet

Ce repository contient le **backend du Customer Portal** basé sur le Microsoft Commercial Marketplace SaaS Accelerator.

### Rôle de ce Repository
- ✅ Customer Portal (ASP.NET Core MVC) - Interface client après achat Marketplace
- ✅ Admin Portal - Gestion des abonnements
- ✅ Webhook Handler - Réception des événements Partner Center
- ✅ Metering Service - Facturation usage Azure Marketplace

### Repository Lié
Le **package Teams** (manifest.json, icons) est dans un repository séparé : `michel-heon/teams-gpt-saas-acc`

---

## 📍 Phase Actuelle : Phase 2.3 - Distribution Client

### Objectif Principal
Permettre aux clients qui ont acheté l'offre sur Azure Marketplace de **télécharger et installer l'application Teams** depuis le Customer Portal.

### Flux Utilisateur Cible
```
1. Client achète sur Azure Marketplace (Plan: dev-01)
2. Webhook active l'abonnement → Status = "Subscribed"
3. Client accède au Customer Portal (sac-02-portal.azurewebsites.net)
4. Section "Installation" apparaît automatiquement
5. Client télécharge appPackage.zip
6. Client installe dans Teams (chargement latéral ou Admin Center)
7. Client envoie premier message au bot
8. Usage tracké dans MeteredAuditLogs
```

---

## ✅ Travaux Complétés (Phase 2.3)

### 1. Section Installation dans Customer Portal
**Fichier modifié** : `src/CustomerSite/Views/Home/_LandingPage.cshtml`

**Commit principal** : `c2d6c9d` - feat: Ajout section Installation dans Customer Portal

**Lignes 197-250** : Code ajouté
```cshtml
@if (Model.SubscriptionStatus == SubscriptionStatusEnumExtension.Subscribed)
{
    <div class="text-white mt-4">
        <span class="cm-section-heading">Installation de l'application Teams</span>
    </div>
    <div class="cm-description-text" style="margin-top: 1.5rem;">
        Merci pour votre abonnement! Vous pouvez maintenant installer l'application Teams...
    </div>
    <div class="mt-3">
        <a class="download-manifest-button" href="@Url.Action("DownloadManifest", "Home")">
            <i class="ms-Icon ms-Icon--Download" aria-hidden="true"></i>
            Télécharger le fichier manifest.zip
        </a>
    </div>
    <div class="cm-installation-links">
        <a href="https://github.com/michel-heon/teams-gpt-saas-acc/blob/main/INSTALLATION.md" target="_blank">
            Guide d'installation
        </a>
        <a href="https://github.com/michel-heon/teams-gpt-saas-acc/blob/main/SUPPORT.md" target="_blank">
            Obtenir de l'aide
        </a>
    </div>
}
```

**Condition d'affichage** : `SubscriptionStatus == Subscribed`

### 2. Logging Diagnostic Ajouté
**Fichier modifié** : `src/CustomerSite/Controllers/HomeController.cs`

**Commit** : `8458cc3` - Add comprehensive logging to HomeController.Index()

**Lignes 215-285** : Logs d'entrée/sortie
```csharp
public async Task<IActionResult> Index(string token = null)
{
    this.logger.Info($"[HOME-INDEX-START] Token present: {!string.IsNullOrEmpty(token)}, User authenticated: {this.User.Identity.IsAuthenticated}");
    this.logger.Info($"[HOME-INDEX-START] User email: {this.CurrentUserEmailAddress}");
    
    // ... construction du modèle ...
    
    this.logger.Info($"[HOME-INDEX-END] Returning Model. ShowWelcomeScreen = {subscriptionExtension.ShowWelcomeScreen}, SubscriptionStatus = {subscriptionExtension.SubscriptionStatus}");
    
    return this.View(subscriptionExtension);
}
```

### 3. Corrections Compilation
**Commit** : `be2adbe` - fix: Add missing closing brace for @if block (RZ1010)

Correction des erreurs :
- RZ1010 : Accolade manquante dans bloc @if
- CS0023 : Type incompatible
- CS0128 : Variable locale dupliquée

---

## 🔴 PROBLÈME BLOQUANT ACTUEL

### Symptôme
Le code modifié **n'est PAS déployé** sur Azure App Service `sac-02-portal`.

### Evidence
- ✅ Code committé (be2adbe, 8458cc3, c2d6c9d)
- ✅ Abonnement test `heon-net` : Status = `Subscribed`
- ❌ Section Installation **PAS VISIBLE** sur le portail
- ❌ Logs applicatifs **PAS VISIBLES** dans Azure

### Hypothèses
1. **Déploiement non effectué** (PLUS PROBABLE)
   - Azure sert encore l'ancien code
   - Besoin de redéployer depuis commit be2adbe

2. **Custom Logger ne log pas dans filesystem**
   - `SaaSClientLogger<T>` écrit uniquement dans Application Insights
   - Logs applicatifs invisibles dans `az webapp log tail`

3. **Cache Azure**
   - App Service cache l'ancienne version
   - Besoin de restart

---

## 🚧 TRAVAIL URGENT À FAIRE

### Priorité #1 : Vérifier et Redéployer

**Actions immédiates** :

1. **Vérifier le commit déployé sur Azure**
   ```bash
   cd /media/psf/Developpement/00-GIT/Commercial-Marketplace-SaaS-Accelerator
   az webapp deployment source show \
     --name sac-02-portal \
     --resource-group rg-saasaccel-teams-gpt-02
   ```

2. **Vérifier l'état du repository local**
   ```bash
   git status
   git log --oneline -5
   git diff origin/main
   ```

3. **Forcer le redéploiement**
   ```bash
   # Option A : Via Azure CLI
   az webapp deployment source sync \
     --name sac-02-portal \
     --resource-group rg-saasaccel-teams-gpt-02
   
   # Option B : Restart App Service (clear cache)
   az webapp restart \
     --name sac-02-portal \
     --resource-group rg-saasaccel-teams-gpt-02
   ```

4. **Vérifier que la section Installation est visible**
   - Aller sur https://sac-02-portal.azurewebsites.net
   - Se connecter avec `heon@cotechnoe.net`
   - Vérifier la présence de "Installation de l'application Teams"

5. **Vérifier les logs applicatifs**
   ```bash
   # Filesystem logs
   az webapp log tail \
     --name sac-02-portal \
     --resource-group rg-saasaccel-teams-gpt-02
   
   # Application Insights (alternative)
   az monitor app-insights query \
     --app sac-02-portal \
     --resource-group rg-saasaccel-teams-gpt-02 \
     --analytics-query "traces | where timestamp > ago(1h) | where message contains 'HOME-INDEX'"
   ```

---

## 📋 TODO LIST COMPLÈTE

### ✅ Phase 2.1-2.2 : Complétés
- [x] Infrastructure SaaS Accelerator déployée
- [x] Manifest Teams finalisé
- [x] Package Teams créé (appPackage.zip)
- [x] Documentation installation (INSTALLATION.md v1.3.1)
- [x] Section Installation ajoutée au Customer Portal

### 🚧 Phase 2.3 : En Cours (BLOQUÉ)
- [ ] **URGENT : Redéployer le code sur Azure**
  - Vérifier commit déployé
  - Forcer synchronisation
  - Valider section Installation visible
  - Confirmer logs applicatifs fonctionnels

### ⏸️ Phase 2.4 : En Attente (après déblocage)
- [ ] **Tester parcours client complet**
  - Achat → Activation → Section Installation visible
  - Téléchargement appPackage.zip
  - Installation Teams (chargement latéral ou Admin Center)
  - Premier message au bot
  - Vérification TeamsUserId en DB
  - Validation MeteredAuditLogs (agrégation horaire)

### ⏸️ Phase 3 : Assets et Production
- [ ] **Créer assets visuels**
  - 5-10 screenshots annotés (installation, usage, analyse doc)
  - 2 vidéos (installation 2-3 min, usage 2-3 min)
  - Format : 1280×720 ou 1920×1080

- [ ] **Documenter configuration production**
  - Guide migration Playground → Production
  - Variables environnement
  - Managed Identity (Azure SQL, Key Vault)
  - Bot Framework endpoints
  - Sécurité (HTTPS, auth, secrets)
  - Conformité GDPR

- [ ] **Valider conformité Teams Store**
  - Vérifier manifest.json contre guidelines
  - Tester validation Partner Center
  - Préparer certification
  - Soumission finale

---

## 🔧 Ressources Azure

### App Service
- **Nom** : `sac-02-portal`
- **URL** : https://sac-02-portal.azurewebsites.net
- **Resource Group** : `rg-saasaccel-teams-gpt-02`
- **Région** : Canada Central
- **Runtime** : ASP.NET Core 8.0

### Base de Données
- **Azure SQL Database**
- **Tables importantes** :
  - `Subscriptions` - Abonnements marketplace
  - `MeteredAuditLogs` - Usage tracking pour facturation
  - `ApplicationLog` - Logs applicatifs (peut contenir les logs SaaSClientLogger)

### Abonnement Test
- **Email** : `heon@cotechnoe.net`
- **Subscription ID** : `b8c115c2-fec3-4b75-ddd9-39ff53febb38`
- **Plan** : `dev-01`
- **Status** : `Subscribed` (depuis 2025-11-03 10:35)

---

## 🎯 Règles pour Copilot

### Quand proposer des modifications de code
1. **TOUJOURS** vérifier l'état du déploiement Azure avant de modifier du code
2. **NE PAS** ajouter de nouvelles fonctionnalités tant que le déploiement actuel n'est pas validé
3. **PRIORISER** le déblocage du déploiement Azure

### Quand proposer des commandes
1. **TOUJOURS** utiliser les chemins absolus pour ce repository
2. **Base path** : `/media/psf/Developpement/00-GIT/Commercial-Marketplace-SaaS-Accelerator`
3. **TOUJOURS** vérifier que les commandes Azure CLI utilisent les bons noms de ressources

### Fichiers à ne PAS modifier (pour l'instant)
- `src/AdminSite/**` - Hors scope Phase 2.3
- `src/WebHook/**` - Fonctionne correctement
- `deployment/**` - Scripts de déploiement validés
- `docs/**` - Documentation SaaS Accelerator originale

### Fichiers clés à surveiller
- `src/CustomerSite/Controllers/HomeController.cs` - Controller principal
- `src/CustomerSite/Views/Home/_LandingPage.cshtml` - Vue avec section Installation
- `src/CustomerSite/Views/Home/Index.cshtml` - Page d'accueil

---

## 📚 Documentation de Référence

### Interne
- `.github/copilot-context.md` - Contexte complet du projet (tous repositories)
- `doc/architecture/phase2-teams-integration.md` - Plan Phase 2
- `doc/architecture/PHASE-2.3-PLAN.md` - Plan détaillé Phase 2.3

### Microsoft
- [SaaS Accelerator GitHub](https://github.com/Azure/Commercial-Marketplace-SaaS-Accelerator)
- [SaaS Fulfillment API v2](https://docs.microsoft.com/azure/marketplace/partner-center-portal/pc-saas-fulfillment-api-v2)
- [Azure Marketplace Metered Billing](https://docs.microsoft.com/azure/marketplace/partner-center-portal/saas-metered-billing)

---

## 💡 Résumé pour Copilot

**Tu travailles sur** : Le backend Customer Portal (ASP.NET Core MVC)

**Objectif actuel** : Afficher la section "Installation de l'application Teams" aux clients abonnés

**Problème bloquant** : Code pas déployé sur Azure (section Installation invisible)

**Priorité #1** : Vérifier et redéployer le code sur `sac-02-portal`

**Ne PAS faire** : Ajouter de nouvelles features avant de débloquer le déploiement

**Commencer par** : Exécuter les commandes de vérification Azure CLI ci-dessus

---

*Document généré le : 2025-11-05*  
*Pour questions : Voir `.github/copilot-context.md` pour le contexte complet*
