wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh; `
chmod +x dotnet-install.sh; `
./dotnet-install.sh -version 8.0.303; `
$ENV:PATH="$HOME/.dotnet:$ENV:PATH"; `
dotnet tool install --global dotnet-ef --version 8.0.6; `

git clone https://github.com/michel-heon/Commercial-Marketplace-SaaS-Accelerator.git --depth 1;

cd ./Commercial-Marketplace-SaaS-Accelerator/deployment; `
.\Deploy.ps1 `
 -WebAppNamePrefix "sac-02" `
 -ResourceGroupForDeployment "rg-saasaccel-teams-gpt-02" `
 -PublisherAdminUsers "heon@cotechnoe.net" `
 -Location "Canada Central" 


 -TenantID "xxxx-xxx-xxx-xxx-xxxx" `
-AzureSubscriptionID "xxx-xx-xx-xx-xxxx" `
-ADApplicationID "xxxx-xxx-xxx-xxx-xxxx" `
-ADApplicationSecret "xxxx-xxx-xxx-xxx-xxxx" `
-ADMTApplicationID "xxxx-xxx-xxx-xxx-xxxx" `
-LogoURLpng "https://company_com/company_logo.png" `
-LogoURLico "https://company_com/company_logo.ico" `
-IsAdminPortalMultiTenant "true" `
-Quiet

✅ If the intallation completed without error complete the folllowing checklist:
   🔵 Add The following URL in PartnerCenter SaaS Technical Configuration
      ➡️ Landing Page section:       https://sac-02-portal.azurewebsites.net/
      ➡️ Connection Webhook section: https://sac-02-portal.azurewebsites.net/api/AzureWebhook
      ➡️ Tenant ID:                  aba0984a-85a2-4fd4-9ae5-0a45d7efc9d2
      ➡️ AAD Application ID section: d3b2710f-1be9-4f89-8834-6273619bd838
Deployment Complete in 18m:13s
DO NOT CLOSE THIS SCREEN.  Please make sure you copy or perform the actions above before closing.
PS /home/michel/Commercial-Marketplace-SaaS-Accelerator/deployment> 



 Deploy Code
   🔵 Deploy Database
      ➡️ Generate SQL schema/data script
Build started...
Build succeeded.
The Entity Framework tools version '8.0.0' is older than that of the runtime '8.0.6'. Update the tools for the latest features and bug fixes. See https://aka.ms/AAc1fbw for more information.
      ➡️ Execute SQL schema/data script
Invoke-Sqlcmd: /home/michel/Commercial-Marketplace-SaaS-Accelerator/deployment/Commercial-Marketplace-SaaS-Accelerator/deployment/Deploy.ps1:579
Line |
 579 |  Invoke-Sqlcmd -InputFile ./script.sql -ConnectionString $ConnectionSt …
     |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | A network-related or instance-specific error occurred while establishing a connection to SQL Server. The server was not found or was not accessible. Verify that the instance name is
     | correct and that SQL Server is configured to allow remote connections. (provider: TCP Provider, error: 35 - An internal exception was caught)