# Makefile for Commercial Marketplace SaaS Accelerator Deployment
# Usage: make [target]

# Include variables
include Makefile.vars

# Shell configuration
SHELL := /bin/bash
.SHELLFLAGS := -ec
.ONESHELL:
export PATH := $(HOME)/.dotnet:$(PATH)

# Phony targets
.PHONY: help install-dotnet build-customer build-admin deploy-customer deploy-admin deploy-all clean check-dotnet deploy-cloudshell

# Default target
help: ## Show this help message
	@echo ""
	@echo "================================================================="
	@echo "  Commercial Marketplace SaaS Accelerator - Makefile"
	@echo "================================================================="
	@echo ""
	@echo "Available targets:"
	@echo ""
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-30s %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make setup              # First time setup"
	@echo "  2. make deploy-customer    # Deploy Customer Portal"
	@echo ""
	@echo "WARNING: For production deployment, use Azure Cloud Shell:"
	@echo "  make deploy-cloudshell     # Ensures x64 compatibility"
	@echo ""

# Install .NET SDK
install-dotnet: ## Install .NET SDK $(DOTNET_VERSION) and EF Core tools
	@echo "Installing .NET SDK $(DOTNET_VERSION)..."
	@if [ ! -f dotnet-install.sh ]; then \
		wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh; \
		chmod +x dotnet-install.sh; \
	fi
	@./dotnet-install.sh --version $(DOTNET_VERSION)
	@echo "Installing dotnet-ef tools $(DOTNET_EF_VERSION)..."
	@$(HOME)/.dotnet/dotnet tool install --global dotnet-ef --version $(DOTNET_EF_VERSION) 2>/dev/null || echo "dotnet-ef already installed"
	@echo "✓ .NET SDK and tools installed"

# Check if .NET is installed
check-dotnet: ## Check if .NET SDK is installed
	@if ! command -v $(HOME)/.dotnet/dotnet &> /dev/null; then \
		echo "✗ .NET SDK not found. Run 'make install-dotnet' first."; \
		exit 1; \
	fi
	@echo "✓ .NET SDK found: $$($(HOME)/.dotnet/dotnet --version)"

# Build Customer Portal
build-customer: check-dotnet ## Build Customer Portal
	@echo "Building Customer Portal..."
	@cd $(CUSTOMER_SITE_DIR) && \
		$(HOME)/.dotnet/dotnet publish -c Release -o $(PUBLISH_DIR)/CustomerSite
	@echo "✓ Customer Portal built"

# Build Admin Portal
build-admin: check-dotnet ## Build Admin Portal
	@echo "Building Admin Portal..."
	@cd $(ADMIN_SITE_DIR) && \
		$(HOME)/.dotnet/dotnet publish -c Release -o $(PUBLISH_DIR)/AdminSite
	@echo "✓ Admin Portal built"

# Package Customer Portal
package-customer: build-customer ## Package Customer Portal into ZIP
	@echo "Packaging Customer Portal..."
	@cd $(PUBLISH_DIR) && \
		rm -f $(CUSTOMER_ZIP) && \
		zip -r $(CUSTOMER_ZIP) CustomerSite/ > /dev/null
	@echo "✓ Customer Portal packaged: $(PUBLISH_DIR)/$(CUSTOMER_ZIP) ($$(du -h $(PUBLISH_DIR)/$(CUSTOMER_ZIP) | cut -f1))"

# Package Admin Portal
package-admin: build-admin ## Package Admin Portal into ZIP
	@echo "Packaging Admin Portal..."
	@cd $(PUBLISH_DIR) && \
		rm -f $(ADMIN_ZIP) && \
		zip -r $(ADMIN_ZIP) AdminSite/ > /dev/null
	@echo "✓ Admin Portal packaged: $(PUBLISH_DIR)/$(ADMIN_ZIP) ($$(du -h $(PUBLISH_DIR)/$(ADMIN_ZIP) | cut -f1))"

# Deploy Customer Portal
deploy-customer: package-customer ## Deploy Customer Portal to Azure
	@echo "Deploying Customer Portal to $(CUSTOMER_WEBAPP)..."
	@cd $(PUBLISH_DIR) && \
		az webapp deploy \
			--resource-group $(RESOURCE_GROUP) \
			--name $(CUSTOMER_WEBAPP) \
			--src-path $(CUSTOMER_ZIP) \
			--type zip \
			--timeout 600
	@echo "✓ Customer Portal deployed to https://$(CUSTOMER_WEBAPP).azurewebsites.net"
	@echo "⏱️  Wait 30 seconds for app to restart, then test:"
	@echo "  https://$(CUSTOMER_WEBAPP).azurewebsites.net"

# Deploy from Cloud Shell (recommended for production)
deploy-cloudshell: ## Deploy Customer Portal from Azure Cloud Shell (x64 compatible)
	@echo "═══════════════════════════════════════════════════════════════"
	@echo "  Cloud Shell Deployment (Recommended for Production)"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo ""
	@if [ -z "$$AZURE_HTTP_USER_AGENT" ]; then \
		echo "⚠️  WARNING: Not running in Azure Cloud Shell!"; \
		echo "   Local builds may have platform compatibility issues."; \
		echo ""; \
		echo "To deploy from Cloud Shell:"; \
		echo "  1. Open https://portal.azure.com"; \
		echo "  2. Click Cloud Shell icon (>_) in top right"; \
		echo "  3. Run the following commands:"; \
		echo ""; \
		echo "     cd ~/Commercial-Marketplace-SaaS-Accelerator/config"; \
		echo "     ./deploy-from-cloudshell.sh"; \
		echo ""; \
		read -p "Continue with local deployment anyway? (yes/no) " -r; \
		echo ""; \
		if [[ ! $$REPLY =~ ^yes$$ ]]; then \
			echo "Deployment cancelled."; \
			exit 1; \
		fi; \
	fi
	@if [ -f deploy-from-cloudshell.sh ]; then \
		chmod +x deploy-from-cloudshell.sh; \
		./deploy-from-cloudshell.sh; \
	else \
		echo "⚠️  Script deploy-from-cloudshell.sh not found!"; \
		echo "   Falling back to standard deployment..."; \
		echo ""; \
		echo "Pulling latest code..."; \
		cd $(PROJECT_ROOT) && git pull origin main; \
		echo "✓ Code updated"; \
		echo ""; \
		$(MAKE) deploy-customer; \
		echo ""; \
		echo "═══════════════════════════════════════════════════════════════"; \
		echo "  Deployment Complete!"; \
		echo "═══════════════════════════════════════════════════════════════"; \
		echo ""; \
		echo "Next Steps:"; \
		echo "  1. Wait 30 seconds for app restart"; \
		echo "  2. Logout: https://$(CUSTOMER_WEBAPP).azurewebsites.net/Account/SignOut"; \
		echo "  3. Clear browser cookies (F12 > Application > Clear storage)"; \
		echo "  4. Test: https://$(CUSTOMER_WEBAPP).azurewebsites.net"; \
	fi
	@echo ""

# Deploy Admin Portal
deploy-admin: package-admin ## Deploy Admin Portal to Azure
	@echo "Deploying Admin Portal to $(ADMIN_WEBAPP)..."
	@cd $(PUBLISH_DIR) && \
		az webapp deploy \
			--resource-group $(RESOURCE_GROUP) \
			--name $(ADMIN_WEBAPP) \
			--src-path $(ADMIN_ZIP) \
			--type zip \
			--timeout 600
	@echo "✓ Admin Portal deployed to https://$(ADMIN_WEBAPP).azurewebsites.net"

# Deploy both portals
deploy-all: deploy-customer deploy-admin ## Deploy both Customer and Admin Portals
	@echo "✓ All portals deployed successfully"

# Clean build artifacts
clean: ## Clean build artifacts and packages
	@echo "Cleaning build artifacts..."
	@rm -rf $(PUBLISH_DIR)/CustomerSite
	@rm -rf $(PUBLISH_DIR)/AdminSite
	@rm -f $(PUBLISH_DIR)/$(CUSTOMER_ZIP)
	@rm -f $(PUBLISH_DIR)/$(ADMIN_ZIP)
	@rm -f dotnet-install.sh
	@echo "✓ Build artifacts cleaned"

# Check Azure CLI
check-azure: ## Check if Azure CLI is logged in
	@echo "Checking Azure CLI..."
	@if ! command -v az &> /dev/null; then \
		echo "✗ Azure CLI not found. Please install it first."; \
		exit 1; \
	fi
	@if ! az account show &> /dev/null; then \
		echo "⚠ Not logged into Azure. Running 'az login'..."; \
		az login; \
	fi
	@echo "✓ Azure CLI ready"
	@echo "  Subscription: $$(az account show --query name -o tsv)"
	@echo "  Account: $$(az account show --query user.name -o tsv)"

# Show deployment info
info: ## Show deployment configuration
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════"
	@echo "  Deployment Configuration"
	@echo "═══════════════════════════════════════════════════════════════"
	@echo ""
	@echo "Azure Resources:"
	@echo "  Resource Group:    $(RESOURCE_GROUP)"
	@echo "  Location:          $(LOCATION)"
	@echo ""
	@echo "Web Applications:"
	@echo "  Customer Portal:   https://$(CUSTOMER_WEBAPP).azurewebsites.net"
	@echo "  Admin Portal:      https://$(ADMIN_WEBAPP).azurewebsites.net"
	@echo ""
	@echo "Backend Services:"
	@echo "  SQL Server:        $(SQL_SERVER).database.windows.net"
	@echo "  Key Vault:         https://$(KEY_VAULT).vault.azure.net"
	@echo ""
	@echo "Authentication:"
	@echo "  Logout URL:        https://$(CUSTOMER_WEBAPP).azurewebsites.net/Account/SignOut"
	@echo "  Login URL:         https://$(CUSTOMER_WEBAPP).azurewebsites.net/Account/SignIn"
	@echo ""

# Setup everything (install + check)
setup: install-dotnet check-azure ## Setup development environment
	@echo "✓ Setup complete! Run 'make deploy-customer' to deploy."
