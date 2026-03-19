provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

variable "law_id" {}
variable "location" {
  default = "centralindia"
}

resource "azurerm_subscription_policy_assignment" "diag" {
  name                 = "deploy-diag-to-law"
  display_name         = "Deploy Diagnostics to Log Analytics"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-LogAnalytics"

  subscription_id = data.azurerm_client_config.current.subscription_id
  location        = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    logAnalytics = {
      value = var.law_id
    }
  })
}

resource "azurerm_role_assignment" "policy_role" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_subscription_policy_assignment.diag.identity[0].principal_id
}
