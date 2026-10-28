# =====================================================================
# Load Balancer - INTERNAL
# =====================================================================
resource "azurerm_lb" "internal" {
  name                = "internal-backend-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal-frontend-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "internal" {
  name            = "internal-backend-pool"
  loadbalancer_id = azurerm_lb.internal.id
}

# Load Balancer Probe
resource "azurerm_lb_probe" "internal" {
  name            = "internal-app-probe"
  loadbalancer_id = azurerm_lb.internal.id
  protocol        = "Tcp"
  port            = 8080
}

# Load Balancer Rules
resource "azurerm_lb_rule" "internal" {
  name                           = "internal-traffic-rule"
  loadbalancer_id                = azurerm_lb.internal.id
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "internal-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal.id]
  probe_id                       = azurerm_lb_probe.internal.id
}
