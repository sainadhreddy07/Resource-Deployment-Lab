# =====================================================================
# Provider
# =====================================================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


# =====================================================================
# Data Sources 
# =====================================================================
data "azurerm_client_config" "current" {}
