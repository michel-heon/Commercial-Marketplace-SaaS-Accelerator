wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh; `
chmod +x dotnet-install.sh; `
./dotnet-install.sh -version 8.0.303; `
$ENV:PATH="$HOME/.dotnet:$ENV:PATH"; `
dotnet tool install --global dotnet-ef --version 8.0.6; `


# 1. Cloner ou pull le repo
cd ~
git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git
# OU si déjà cloné:
cd ~/Commercial-Marketplace-SaaS-Accelerator
git pull origin main


# 2. Naviguer vers deployment
cd deployment

# 3. Exécuter Upgrade.ps1
./Upgrade.ps1 -WebAppNamePrefix "sac-02" -ResourceGroupForDeployment "rg-saasaccel-teams-gpt-02"


/Upgrade-CustomerPortal.ps1 -WebAppNamePrefix "sac-02" -ResourceGroupForDeployment "rg-saasaccel-teams-gpt-02"



cd /home/michel/Commercial-Marketplace-SaaS-Accelerator
git pull
cd src/CustomerSite
dotnet publish -c Release -o ../../Publish/CustomerSite
cd ../../Publish
zip -r CustomerSite.zip CustomerSite/
az webapp deploy --resource-group rg-saasaccel-teams-gpt-02 --name sac-02-portal --src-path CustomerSite.zip --type zip




bash <(curl -s https://raw.githubusercontent.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator/main/deployment/deploy-from-cloudshell.sh)

az webapp log tail --name sac-02-portal --resource-group rg-saasaccel-teams-gpt-02