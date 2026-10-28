variable "subscription_id" {}

variable "location" {
  default = "East US 2"
}

variable "resource_group_name" {
  default = "rg-resource-lab"
}

variable "vnet_name" {
  default = "vnet-resource-lab"
}

variable "subnet_name" {
  default = "subnet-resource-lab"
}

variable "storage_account_name" {
  default = "rsrclabsa001"
}

variable "vm_count" {
  default = 2
}

variable "vm_name" {
  default = "linux-vm-resource-lab"
}

variable "vm_size" {
  default = "Standard_D2s_v6"
}

variable "admin_username" {
  default = "linuxuser1"
}

variable "admin_password" {
  default = "P@ssw0rd!234"
}

variable "load_balancer_name" {
  default = "lb-resource-lab"
}

variable "recovery_vault_name" {
  default = "vault-resource-lab"
}

variable "backup_policy_name" {
  default = "policy-daily-backup"
}

variable "backup_time" {
  default = "23:00"
}

variable "retention_days" {
  default = 7
}

variable "key_vault_name" {
  default = "resourcelab-kv-001"
}

