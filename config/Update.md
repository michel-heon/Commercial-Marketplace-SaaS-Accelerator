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