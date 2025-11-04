# Makefile for Commercial Marketplace SaaS Accelerator Deployment
# Usage: make [target]

# Include variables
include Makefile.vars

# Shell configuration
SHELL := /bin/bash
.SHELLFLAGS := -ec
.ONESHELL:
export PATH := $(HOME)/.dotnet:$(PATH)

# Colors for output
COLOR_RESET   := \033[0m
COLOR_INFO    := \033[36m
COLOR_SUCCESS := \033[32m
COLOR_WARNING := \033[33m
COLOR_ERROR   := \033[31m

# Phony targets
.PHONY: help install-dotnet build-customer build-admin deploy-customer deploy-admin deploy-all clean check-dotnet \
        git-pull git-status update-and-deploy restart-customer restart-admin logs-customer logs-admin

# Default target
help: ## Show this help message
	@echo "$(COLOR_INFO)═══════════════════════════════════════════════════════$(COLOR_RESET)"
	@echo "$(COLOR_INFO)  Commercial Marketplace SaaS Accelerator - Makefile$(COLOR_RESET)"
	@echo "$(COLOR_INFO)═══════════════════════════════════════════════════════$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_WARNING)Setup Commands:$(COLOR_RESET)"
	@grep -E '^(setup|install-dotnet|check-dotnet|check-azure):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_SUCCESS)%-25s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_WARNING)Build & Package Commands:$(COLOR_RESET)"
	@grep -E '^(build-customer|build-admin|package-customer|package-admin):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_SUCCESS)%-25s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_WARNING)Deployment Commands:$(COLOR_RESET)"
	@grep -E '^(deploy-customer|deploy-admin|deploy-all|quick-deploy|update-and-deploy):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_SUCCESS)%-25s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_WARNING)Git Commands:$(COLOR_RESET)"
	@grep -E '^(git-pull|git-status):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_SUCCESS)%-25s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_WARNING)Maintenance Commands:$(COLOR_RESET)"
	@grep -E '^(restart-customer|restart-admin|logs-customer|logs-admin|info|clean):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_SUCCESS)%-25s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""

# Install .NET SDK
install-dotnet: ## Install .NET SDK $(DOTNET_VERSION) and EF Core tools
	@echo "$(COLOR_INFO)Installing .NET SDK $(DOTNET_VERSION)...$(COLOR_RESET)"
	@if [ ! -f dotnet-install.sh ]; then \
		wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh; \
		chmod +x dotnet-install.sh; \
	fi
	@./dotnet-install.sh --version $(DOTNET_VERSION)
	@echo "$(COLOR_INFO)Installing dotnet-ef tools $(DOTNET_EF_VERSION)...$(COLOR_RESET)"
	@$(HOME)/.dotnet/dotnet tool install --global dotnet-ef --version $(DOTNET_EF_VERSION) 2>/dev/null || echo "dotnet-ef already installed"
	@echo "$(COLOR_SUCCESS)✓ .NET SDK and tools installed$(COLOR_RESET)"

# Check if .NET is installed
check-dotnet: ## Check if .NET SDK is installed
	@if ! command -v $(HOME)/.dotnet/dotnet &> /dev/null; then \
		echo "$(COLOR_ERROR)✗ .NET SDK not found. Run 'make install-dotnet' first.$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_SUCCESS)✓ .NET SDK found: $$($(HOME)/.dotnet/dotnet --version)$(COLOR_RESET)"

# Build Customer Portal
build-customer: check-dotnet ## Build Customer Portal
	@echo "$(COLOR_INFO)Building Customer Portal...$(COLOR_RESET)"
	@cd $(CUSTOMER_SITE_DIR) && \
		$(HOME)/.dotnet/dotnet publish -c Release -o $(PUBLISH_DIR)/CustomerSite
	@echo "$(COLOR_SUCCESS)✓ Customer Portal built$(COLOR_RESET)"

# Build Admin Portal
build-admin: check-dotnet ## Build Admin Portal
	@echo "$(COLOR_INFO)Building Admin Portal...$(COLOR_RESET)"
	@cd $(ADMIN_SITE_DIR) && \
		$(HOME)/.dotnet/dotnet publish -c Release -o $(PUBLISH_DIR)/AdminSite
	@echo "$(COLOR_SUCCESS)✓ Admin Portal built$(COLOR_RESET)"

# Package Customer Portal
package-customer: build-customer ## Package Customer Portal into ZIP
	@echo "$(COLOR_INFO)Packaging Customer Portal...$(COLOR_RESET)"
	@cd $(PUBLISH_DIR) && \
		rm -f $(CUSTOMER_ZIP) && \
		zip -r $(CUSTOMER_ZIP) CustomerSite/ > /dev/null
	@echo "$(COLOR_SUCCESS)✓ Customer Portal packaged: $(PUBLISH_DIR)/$(CUSTOMER_ZIP) ($$(du -h $(PUBLISH_DIR)/$(CUSTOMER_ZIP) | cut -f1))$(COLOR_RESET)"

# Package Admin Portal
package-admin: build-admin ## Package Admin Portal into ZIP
	@echo "$(COLOR_INFO)Packaging Admin Portal...$(COLOR_RESET)"
	@cd $(PUBLISH_DIR) && \
		rm -f $(ADMIN_ZIP) && \
		zip -r $(ADMIN_ZIP) AdminSite/ > /dev/null
	@echo "$(COLOR_SUCCESS)✓ Admin Portal packaged: $(PUBLISH_DIR)/$(ADMIN_ZIP) ($$(du -h $(PUBLISH_DIR)/$(ADMIN_ZIP) | cut -f1))$(COLOR_RESET)"

# Deploy Customer Portal
deploy-customer: package-customer ## Deploy Customer Portal to Azure
	@echo "$(COLOR_INFO)Deploying Customer Portal to $(CUSTOMER_WEBAPP)...$(COLOR_RESET)"
	@cd $(PUBLISH_DIR) && \
		az webapp deploy \
			--resource-group $(RESOURCE_GROUP) \
			--name $(CUSTOMER_WEBAPP) \
			--src-path $(CUSTOMER_ZIP) \
			--type zip
	@echo "$(COLOR_SUCCESS)✓ Customer Portal deployed to https://$(CUSTOMER_WEBAPP).azurewebsites.net$(COLOR_RESET)"

# Deploy Admin Portal
deploy-admin: package-admin ## Deploy Admin Portal to Azure
	@echo "$(COLOR_INFO)Deploying Admin Portal to $(ADMIN_WEBAPP)...$(COLOR_RESET)"
	@cd $(PUBLISH_DIR) && \
		az webapp deploy \
			--resource-group $(RESOURCE_GROUP) \
			--name $(ADMIN_WEBAPP) \
			--src-path $(ADMIN_ZIP) \
			--type zip
	@echo "$(COLOR_SUCCESS)✓ Admin Portal deployed to https://$(ADMIN_WEBAPP).azurewebsites.net$(COLOR_RESET)"

# Deploy both portals
deploy-all: deploy-customer deploy-admin ## Deploy both Customer and Admin Portals
	@echo "$(COLOR_SUCCESS)✓ All portals deployed successfully$(COLOR_RESET)"

# Quick deploy customer (for development)
quick-deploy: ## Quick deploy Customer Portal (build + deploy)
	@echo "$(COLOR_INFO)Quick deploy Customer Portal...$(COLOR_RESET)"
	@$(MAKE) deploy-customer
	@echo "$(COLOR_SUCCESS)✓ Customer Portal deployed$(COLOR_RESET)"

# Clean build artifacts
clean: ## Clean build artifacts and packages
	@echo "$(COLOR_INFO)Cleaning build artifacts...$(COLOR_RESET)"
	@rm -rf $(PUBLISH_DIR)/CustomerSite
	@rm -rf $(PUBLISH_DIR)/AdminSite
	@rm -f $(PUBLISH_DIR)/$(CUSTOMER_ZIP)
	@rm -f $(PUBLISH_DIR)/$(ADMIN_ZIP)
	@rm -f dotnet-install.sh
	@echo "$(COLOR_SUCCESS)✓ Build artifacts cleaned$(COLOR_RESET)"

# Check Azure CLI
check-azure: ## Check if Azure CLI is logged in
	@echo "$(COLOR_INFO)Checking Azure CLI...$(COLOR_RESET)"
	@if ! command -v az &> /dev/null; then \
		echo "$(COLOR_ERROR)✗ Azure CLI not found. Please install it first.$(COLOR_RESET)"; \
		exit 1; \
	fi
	@if ! az account show &> /dev/null; then \
		echo "$(COLOR_WARNING)⚠ Not logged into Azure. Running 'az login'...$(COLOR_RESET)"; \
		az login; \
	fi
	@echo "$(COLOR_SUCCESS)✓ Azure CLI ready$(COLOR_RESET)"
	@echo "  Subscription: $$(az account show --query name -o tsv)"
	@echo "  Account: $$(az account show --query user.name -o tsv)"

# Show deployment info
info: ## Show deployment configuration
	@echo "$(COLOR_INFO)Deployment Configuration:$(COLOR_RESET)"
	@echo "  Resource Group: $(COLOR_SUCCESS)$(RESOURCE_GROUP)$(COLOR_RESET)"
	@echo "  Location: $(COLOR_SUCCESS)$(LOCATION)$(COLOR_RESET)"
	@echo "  Customer Portal: $(COLOR_SUCCESS)https://$(CUSTOMER_WEBAPP).azurewebsites.net$(COLOR_RESET)"
	@echo "  Admin Portal: $(COLOR_SUCCESS)https://$(ADMIN_WEBAPP).azurewebsites.net$(COLOR_RESET)"
	@echo "  SQL Server: $(COLOR_SUCCESS)$(SQL_SERVER).database.windows.net$(COLOR_RESET)"
	@echo "  Key Vault: $(COLOR_SUCCESS)https://$(KEY_VAULT).vault.azure.net$(COLOR_RESET)"

# Setup everything (install + check)
setup: install-dotnet check-azure ## Setup development environment
	@echo "$(COLOR_SUCCESS)✓ Setup complete! Run 'make deploy-customer' to deploy.$(COLOR_RESET)"

# Git Commands
git-status: ## Show git repository status
	@echo "$(COLOR_INFO)Git Repository Status:$(COLOR_RESET)"
	@cd $(PROJECT_ROOT) && git status

git-pull: ## Pull latest changes from git
	@echo "$(COLOR_INFO)Pulling latest changes from git...$(COLOR_RESET)"
	@cd $(PROJECT_ROOT) && git pull origin main
	@echo "$(COLOR_SUCCESS)✓ Repository updated$(COLOR_RESET)"

# Update from git and deploy
update-and-deploy: git-pull deploy-customer ## Pull latest changes and deploy Customer Portal
	@echo "$(COLOR_SUCCESS)✓ Update and deployment complete!$(COLOR_RESET)"

# Restart webapps
restart-customer: ## Restart Customer Portal webapp
	@echo "$(COLOR_INFO)Restarting Customer Portal...$(COLOR_RESET)"
	@az webapp restart --name $(CUSTOMER_WEBAPP) --resource-group $(RESOURCE_GROUP)
	@echo "$(COLOR_SUCCESS)✓ Customer Portal restarted$(COLOR_RESET)"

restart-admin: ## Restart Admin Portal webapp
	@echo "$(COLOR_INFO)Restarting Admin Portal...$(COLOR_RESET)"
	@az webapp restart --name $(ADMIN_WEBAPP) --resource-group $(RESOURCE_GROUP)
	@echo "$(COLOR_SUCCESS)✓ Admin Portal restarted$(COLOR_RESET)"

# View logs
logs-customer: ## Stream logs from Customer Portal
	@echo "$(COLOR_INFO)Streaming logs from Customer Portal (Ctrl+C to stop)...$(COLOR_RESET)"
	@az webapp log tail --name $(CUSTOMER_WEBAPP) --resource-group $(RESOURCE_GROUP)

logs-admin: ## Stream logs from Admin Portal
	@echo "$(COLOR_INFO)Streaming logs from Admin Portal (Ctrl+C to stop)...$(COLOR_RESET)"
	@az webapp log tail --name $(ADMIN_WEBAPP) --resource-group $(RESOURCE_GROUP)

# Browse webapps
browse-customer: ## Open Customer Portal in browser
	@echo "$(COLOR_INFO)Opening Customer Portal in browser...$(COLOR_RESET)"
	@az webapp browse --name $(CUSTOMER_WEBAPP) --resource-group $(RESOURCE_GROUP)

browse-admin: ## Open Admin Portal in browser
	@echo "$(COLOR_INFO)Opening Admin Portal in browser...$(COLOR_RESET)"
	@az webapp browse --name $(ADMIN_WEBAPP) --resource-group $(RESOURCE_GROUP)

# Full workflow: update, build, and deploy
full-deploy: check-azure git-pull ## Complete workflow: git pull + build + deploy Customer Portal
	@echo "$(COLOR_INFO)═══════════════════════════════════════════════════════$(COLOR_RESET)"
	@echo "$(COLOR_INFO)Starting full deployment workflow...$(COLOR_RESET)"
	@echo "$(COLOR_INFO)═══════════════════════════════════════════════════════$(COLOR_RESET)"
	@$(MAKE) deploy-customer
	@echo ""
	@echo "$(COLOR_SUCCESS)═══════════════════════════════════════════════════════$(COLOR_RESET)"
	@echo "$(COLOR_SUCCESS)✓ Full deployment complete!$(COLOR_RESET)"
	@echo "$(COLOR_SUCCESS)═══════════════════════════════════════════════════════$(COLOR_RESET)"
	@echo "$(COLOR_INFO)Customer Portal: https://$(CUSTOMER_WEBAPP).azurewebsites.net$(COLOR_RESET)"

