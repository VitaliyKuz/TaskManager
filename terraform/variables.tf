variable "azure_subscription_id" {
  description = "Azure Subscription ID"
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
}

variable "azure_client_id" {
  description = "Azure Client ID"
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  sensitive   = true
}

variable "gcp_project" {
  description = "Google Cloud Project ID"
}

variable "gcp_region" {
  description = "Preferred Google Cloud Region"
  default     = "us-central1"
}
