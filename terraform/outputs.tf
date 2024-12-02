output "azure_resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "gcp_instance_ip" {
  value = google_compute_instance.main.network_interface[0].access_config[0].nat_ip
}
