# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.25.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg_task_02" {
  name      = "rg_task_02"
  location  = var.location

  tags = {
        Environment = "Task 02"
    }
}