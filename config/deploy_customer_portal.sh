#!/bin/bash
cd /home/michel/Commercial-Marketplace-SaaS-Accelerator

# Étape 1: Build le Customer Portal avec le code de debug
cd src/CustomerSite
dotnet publish -c Release -o ../../Publish/CustomerSite

# Étape 2: Créer l'archive
cd ../../Publish
zip -r CustomerSite.zip CustomerSite/

# Étape 3: Déployer uniquement le Customer Portal
az webapp deploy --resource-group rg-saasaccel-teams-gpt-02 --name sac-02-portal --src-path CustomerSite.zip --type zip
