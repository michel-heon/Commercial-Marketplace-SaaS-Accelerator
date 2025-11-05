# Guide de diagnostic - Azure Log Stream

## Objectif
Diagnostiquer pourquoi la section "Installation de l'application Teams" n'apparaît pas sur le portail client.

## Logs ajoutés

### 1. HomeController.cs - Index Method

**Au démarrage de la méthode** (ligne ~215):
```
[HOME-INDEX-START] Token present: {true/false}, User authenticated: {true/false}
[HOME-INDEX-START] User email: {email}
```

**Avant de retourner la vue** (lignes ~285, 303, 308):
```
[HOME-INDEX-END] Authenticated but no token - returning welcome screen. SubscriptionStatus = {status}
[HOME-INDEX-END] Returning Model. ShowWelcomeScreen = {true/false}, SubscriptionStatus = {status}
```

### 2. _LandingPage.cshtml - Partial View

**Au début du rendu** (ligne ~11):
```
[LANDING-PAGE-START] Rendering Landing Page
[LANDING-PAGE] Model is null: {true/false}
[LANDING-PAGE] ShowWelcomeScreen = {true/false}
[LANDING-PAGE] SubscriptionStatus = '{status}'
```

**Avant la section Installation** (ligne ~203):
```
[LANDING-PAGE-INSTALLATION] Checking Installation section condition
[LANDING-PAGE-INSTALLATION] SubscriptionStatus = '{status}'
[LANDING-PAGE-INSTALLATION] Condition (SubscriptionStatus == Subscribed): {true/false}
[LANDING-PAGE-INSTALLATION] ✓ WILL RENDER Installation section
  OU
[LANDING-PAGE-INSTALLATION] ✗ WILL NOT RENDER Installation section (Status is: '{status}')
```

## Comment accéder aux logs

### Via Azure Portal
1. Aller sur https://portal.azure.com
2. Naviguer vers App Service → `sac-02-portal`
3. Menu latéral → Monitoring → Log stream

### Via Azure CLI
```bash
az webapp log tail --name sac-02-portal --resource-group rg-saasaccel-teams-gpt-02
```

## Prochaines étapes

1. **Déployer** le nouveau code avec les logs
2. **Ouvrir Azure Log Stream**
3. **Accéder au portail** https://sac-02-portal.azurewebsites.net
4. **Observer les logs** pour voir la valeur de SubscriptionStatus

## Commit actuel

- **Commit**: 8458cc3
- **Fichiers modifiés**:
  - `src/CustomerSite/Controllers/HomeController.cs` 
  - `src/CustomerSite/Views/Home/_LandingPage.cshtml`
