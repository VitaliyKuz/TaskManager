resource "azurerm_resource_group" "main" {
  name     = "task_manager_rg"
  location = "East US"
}

resource "azurerm_storage_account" "main" {
  name                     = "taskmanagerstorage"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "google_compute_instance" "main" {
  name         = "task-manager-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
