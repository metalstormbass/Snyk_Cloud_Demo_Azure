# Azure Vulnerable VM
resource "azurerm_virtual_network" "azure_goof_network" {
  name                = "${var.owner}vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.owner-rg.location
  resource_group_name = azurerm_resource_group.owner-rg.name
}

resource "azurerm_subnet" "azure_goof_subnet" {
  name                 = "${var.owner}subnet"
  resource_group_name  = azurerm_resource_group.owner-rg.name
  virtual_network_name = azurerm_virtual_network.azure_goof_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "azure_goof_public_ip" {
  name                = "${var.owner}publicip"
  location            = azurerm_resource_group.owner-rg.location
  resource_group_name = azurerm_resource_group.owner-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "azure_goof_nsg" {
  name                = "${var.owner}securitygroup"
  location            = azurerm_resource_group.owner-rg.location
  resource_group_name = azurerm_resource_group.owner-rg.name

  security_rule {
    name                       = "Everything"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "azure_goof_nic" {
  name                = "${var.owner}nic"
  location            = azurerm_resource_group.owner-rg.location
  resource_group_name = azurerm_resource_group.owner-rg.name

  ip_configuration {
    name                          = "${var.owner}nicconfig"
    subnet_id                     = azurerm_subnet.azure_goof_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_goof_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "azure_goof_nic_sg_association" {
  network_interface_id      = azurerm_network_interface.azure_goof_nic.id
  network_security_group_id = azurerm_network_security_group.azure_goof_nsg.id
}

resource "azurerm_storage_account" "azure_goof_storage_account" {
  name                     = "${var.owner}storageaccountvm"
  location                 = azurerm_resource_group.owner-rg.location
  resource_group_name      = azurerm_resource_group.owner-rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



resource "azurerm_linux_virtual_machine" "azure_goof_vm" {
  name                  = "${var.owner}vm"
  location              = azurerm_resource_group.owner-rg.location
  resource_group_name   = azurerm_resource_group.owner-rg.name
  network_interface_ids = [azurerm_network_interface.azure_goof_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.owner}osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "${var.owner}azuregoof"
  admin_username = "azureuser"
  admin_password = "vpn123"
  disable_password_authentication = false
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.azure_goof_storage_account.primary_blob_endpoint
  }
}