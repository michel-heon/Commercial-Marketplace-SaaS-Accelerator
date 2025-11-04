# Changelog - Intégration Teams GPT

Modifications apportées au SaaS Accelerator pour l'intégration de l'Assistant GPT Teams.

## [1.0.0] - 2025-11-04

### Ajouté

#### Customer Portal - Section Installation Teams
- **Fichier modifié**: `src/CustomerSite/Views/Home/_LandingPage.cshtml`
- **Ligne d'insertion**: Après le panneau de détails d'abonnement (ligne ~220)
- **Condition d'affichage**: Visible uniquement pour `SubscriptionStatus == Subscribed`

**Composants ajoutés**:
1. **Heading section**: "Installation de l'application Teams" avec classe `cm-section-heading`
2. **Panneau d'instructions**: 
   - Message de confirmation: "Votre abonnement est maintenant actif !"
   - Instructions en deux étapes
3. **Carte 1 - Téléchargement**:
   - Titre: "Étape 1 : Télécharger le package"
   - Icône: SVG download (Bootstrap Icons)
   - Bouton: Lien vers `https://github.com/Cotechnoe/Assistant-GPT-Teams/blob/main/appPackage.zip`
   - Classe CSS: `cm-button-default btn-sm`
4. **Carte 2 - Guide d'installation**:
   - Titre: "Étape 2 : Suivre le guide d'installation"
   - Icône: SVG book (Bootstrap Icons)
   - Bouton: Lien vers `https://github.com/Cotechnoe/Assistant-GPT-Teams/blob/main/INSTALLATION.md`
   - Classe CSS: `cm-button-default btn-sm`
5. **Alert d'aide**:
   - Classe: `alert alert-info`
   - Icône: SVG info-circle (Bootstrap Icons)
   - Liens: SUPPORT.md (GitHub) et support@cotechnoe.com (email)

**Classes CSS utilisées**:
- `cm-section-heading`: Heading existant du SaaS Accelerator
- `cm-panel-default`: Panneau par défaut du SaaS Accelerator
- `cm-button-default`: Bouton par défaut du SaaS Accelerator
- Bootstrap 5: `card`, `alert`, `row`, `col-*`, `mb-*`, `mt-*`

**Icônes SVG**:
- Bootstrap Icons inline (download, book, info-circle)
- Couleur: `currentColor` (hérite du texte parent)
- Dimensions: 20×20 pixels

**Liens externes**:
- Tous les liens s'ouvrent dans un nouvel onglet (`target="_blank"`)
- GitHub repository: `Cotechnoe/Assistant-GPT-Teams`
- Email: `support@cotechnoe.com`

### Technique

**Compatibilité**:
- ASP.NET Core MVC (Razor syntax)
- Bootstrap 5 (grid, cards, alerts)
- Responsive design (col-md-6 pour écrans moyens et plus)

**Intégration**:
- Aucune modification du contrôleur requise
- Aucune modification du modèle requise
- Utilise le modèle existant `SubscriptionResultExtension`
- Condition basée sur l'enum `SubscriptionStatusEnumExtension.Subscribed`

**Maintenance**:
- URLs GitHub hardcodées (à mettre à jour si changement de repository)
- Email de support hardcodé (à mettre à jour si changement)
- Textes en français (à internationaliser si multilingue souhaité)

### Notes de déploiement

**Aucun impact sur**:
- Base de données (aucune migration requise)
- Configuration (aucune variable d'environnement ajoutée)
- Dépendances (aucun package NuGet ajouté)
- API (aucune route ajoutée)

**Test recommandé**:
1. Créer un abonnement via Azure Marketplace
2. Activer l'abonnement (statut → `Subscribed`)
3. Vérifier l'affichage de la section Installation
4. Tester les liens (téléchargement, documentation, support)
5. Vérifier la responsivité (mobile, tablette, desktop)

### Références

- **Distribution repository**: https://github.com/Cotechnoe/Assistant-GPT-Teams
- **Guide d'installation**: appPackage/distribution-snapshot/INSTALLATION.md (version 1.3.1)
- **Support**: appPackage/distribution-snapshot/SUPPORT.md
- **Architecture**: doc/architecture/distribution-repository.md

---

## TODO - Phase suivante

### Email de post-activation (Todo 6 - Partie 2)

**Objectif**: Envoyer un email automatique après l'activation de l'abonnement avec les instructions d'installation.

**Composants à créer/modifier**:
1. **Template email**: `src/CustomerSite/EmailTemplates/TeamInstallation.html`
   - Sujet: "Installation de votre Assistant GPT Teams"
   - Corps: Instructions + liens vers GitHub
   - Utiliser les templates existants comme base
2. **Service email**: Modifier `src/Services/Services/EmailService.cs`
   - Ajouter méthode `SendTeamInstallationInstructionsAsync()`
   - Paramètres: `customerEmail`, `customerName`, `subscriptionId`
3. **Controller**: Modifier `src/CustomerSite/Controllers/HomeController.cs`
   - Dans méthode `SubscriptionOperation()` après activation réussie
   - Appeler `emailService.SendTeamInstallationInstructionsAsync()`
4. **Configuration**: `src/CustomerSite/appsettings.json`
   - Vérifier configuration SMTP existante
   - Ajouter paramètres d'email si nécessaire

**Références à consulter**:
- Templates existants dans `src/CustomerSite/EmailTemplates/`
- `IEmailService` interface dans `src/Services/Contracts/`
- `EmailService` implementation dans `src/Services/Services/`
