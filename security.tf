# =====================================================================
# Key Vault
# =====================================================================
resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
    key_permissions         = ["Get", "List", "Create", "Update", "Delete", "Recover", "Backup", "Restore", "Purge"]
    certificate_permissions = ["Get", "List", "Create", "Update", "Delete", "Recover", "Backup", "Restore", "Purge"]
  }
}

# =====================================================================
# Backup (Recovery Services Vault)
# =====================================================================
resource "azurerm_recovery_services_vault" "main" {
  name                = var.recovery_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}

# =====================================================================
# Backup (Policy)
# =====================================================================
resource "azurerm_backup_policy_vm" "daily" {
  name                = var.backup_policy_name
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_days
  }
}

# =====================================================================
# Backup (VM Association - Protected VM)
# =====================================================================
resource "azurerm_backup_protected_vm" "linux" {
  count               = var.vm_count
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.main[count.index].id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
