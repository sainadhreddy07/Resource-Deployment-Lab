
# =====================================================================
# Public IP
# =====================================================================
resource "azurerm_public_ip" "main" {
  name                = "pip-AZD-RL"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =====================================================================
# Load Balancer
# =====================================================================
resource "azurerm_lb" "main" {
  name                = var.load_balancer_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.main.id
}

# Load Balancer Probe
resource "azurerm_lb_probe" "main" {
  name                = "http-application-probe"
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = "Http"
  port                = 80
  request_path        = "/healthz"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rules
resource "azurerm_lb_rule" "main" {
  name                           = "http-web-rule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
}

resource "azurerm_lb_nat_rule" "ssh" {
  count                          = var.vm_count
  name                           = "ssh-management-vm-${count.index}"
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 50000 + count.index
  backend_port                   = 22
  frontend_ip_configuration_name = "frontend-ip"
}

resource "azurerm_network_interface_nat_rule_association" "linux" {
  count                 = var.vm_count
  network_interface_id  = azurerm_network_interface.linux[count.index].id
  ip_configuration_name = "linux-ipconfig"
  nat_rule_id           = azurerm_lb_nat_rule.ssh[count.index].id
}
