# =====================================================================
# Linux NIC
# =====================================================================
resource "azurerm_network_interface" "linux" {
  count               = var.vm_count #-->  3*
  name                = "linux-vm-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "linux-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

# =====================================================================
# Mapping VM NIC with LB Backend Pool
# =====================================================================
resource "azurerm_network_interface_backend_address_pool_association" "linux" {
  count                   = var.vm_count #--> 3**
  network_interface_id    = azurerm_network_interface.linux[count.index].id
  ip_configuration_name   = "linux-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# =====================================================================
# Key Vault Secret - VM Admin Password
# =====================================================================
data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  key_vault_id = azurerm_key_vault.main.id
}

# =====================================================================
# Linux VM
# =====================================================================
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.vm_name}-${count.index}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = data.azurerm_key_vault_secret.vm_password.value
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.linux[count.index].id]

  os_disk {
    name                 = "linux-os-disk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  #Adding this block after running tf plan -out=rsrcplan-2 since it warned about destroying the VM, ddisks and backup.
  lifecycle {
    ignore_changes = [
      admin_password, os_disk, source_image_reference
    ]
  }
}

# =====================================================================
# Data Disk 1 - Read-Only
# =====================================================================
resource "azurerm_managed_disk" "read_only" {
  count                = var.vm_count
  name                 = "linux-ddsk-ro-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 5
}

resource "azurerm_virtual_machine_data_disk_attachment" "read_only" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.read_only[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = 1
  caching            = "ReadOnly"
}

# =====================================================================
# Data Disk 2 - Read-Write
# =====================================================================
resource "azurerm_managed_disk" "read_write" {
  count                = var.vm_count
  name                 = "linux-ddsk-rw-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 5
}

resource "azurerm_virtual_machine_data_disk_attachment" "read_write" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.read_write[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = 2
  caching            = "ReadWrite"
}

# =====================================================================
# Data Disk 3 - None Caching
# =====================================================================
resource "azurerm_managed_disk" "none_caching" {
  count                = var.vm_count
  name                 = "linux-ddsk-none-${count.index}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 5
}

resource "azurerm_virtual_machine_data_disk_attachment" "none_caching" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.none_caching[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = 3
  caching            = "None"
}

