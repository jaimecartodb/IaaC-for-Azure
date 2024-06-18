provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "myrg" {
  name     = "myResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "mynetwork" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.mynetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "mynic" {
  name                = "myNIC"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                  = "myVM"
  resource_group_name   = azurerm_resource_group.myrg.name
  location              = azurerm_resource_group.myrg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.mynic.id]
  disable_password_authentication = true

  os_disk {
    caching                   = "ReadWrite"
    storage_account_type      = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDT5Y3cpT6P7v/wszaMIPK61ZvsmS7fccix/lEDXOrccq1CKk4tXAL4uRY9OdvWoFGeH04D4RFrGVX89fYGhFa+KJD0SOpWztWsK50xsLhzId6mFabS24JE/ZkVrGmQo4K+kqbJul3WwRhk4N+t8uTXGLS3S3hKWUn3h0DqIDulKDt/XBuEYl4opsbllLi/VQKVU5gbcOJPYZjLKcMS5uAQipnt66cHMuWK73+teVLQyKa48uYaXE89tT4w2H9R7Xyx5aAl6J2WlJmmHf97sDY5rC7I6ENFIUAsCo1zhsI39MQaSGQb2V4UnFmpQVDFH+/AC+NZbZeWfHirCgDtAUptc9UwYyHSMzROmrddzd3CBpZZl/YTgNxfJa/StsfjXTRZLz87uMY8X/SXU6uSw25nL1UrCy+q9mP1PEYwVUZS65vg1IUI38lWVmgfKD+47LYDVm4Yumb5993B0xhmWMVh30hM8nZcAqCV8Qtwjr12KfOqFuViZ+V32jE1+eiXYuETDK7yh5MPKQrmLNT8mCF0iT8oDYMF3Jp4CFrsaCQGBbOuAFeyieuHSNs9vKdqXkQLGXo2Rvrx1EwpxARVwgauuGFxt7cYU8y3vKmDmM64yd1FdfEPrfsWtgPm1hxQFucuocvptaf8m0ogB0rZwemPz3JyBCZoLOYacdWkgTHV6Q== jaimedemoranavarro@gmail.com
EOF
  }
}

resource "azurerm_key_vault" "mykeyvault" {
  name                        = "myKeyVault3"
  location                    = azurerm_resource_group.myrg.location
  resource_group_name         = azurerm_resource_group.myrg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
    ]
  }
}

# Crear un secreto en el Key Vault
resource "azurerm_key_vault_secret" "example" {
  name         = "exampleSecret3"
  value        = "MySecretValue"
  key_vault_id = azurerm_key_vault.mykeyvault.id
}

data "azurerm_client_config" "current" {}
