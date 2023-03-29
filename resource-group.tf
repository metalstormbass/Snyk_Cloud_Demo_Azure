# Create a resource group for victim network
resource "azurerm_resource_group" "owner-rg" {
  name     = "${var.owner}-rg"
  location = var.location
}