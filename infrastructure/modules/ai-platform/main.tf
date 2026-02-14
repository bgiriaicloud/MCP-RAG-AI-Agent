variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_network" {
  description = "VPC Network ID"
  type        = string
}

# Enable required APIs
resource "google_project_service" "aiplatform" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Create a GCS bucket for Vector Search data
resource "google_storage_bucket" "vector_search_data" {
  name          = "${var.project_id}-vector-search-data"
  location      = var.region
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
}

# Note: Vertex AI Vector Search Index and Endpoint creation
# is typically done via gcloud or Python SDK due to complexity
# This is a placeholder for the infrastructure setup

output "vector_search_bucket" {
  value = google_storage_bucket.vector_search_data.name
}

output "vector_search_endpoint" {
  value = "projects/${var.project_id}/locations/${var.region}/indexEndpoints/placeholder"
  description = "Placeholder - Create actual endpoint via gcloud or SDK"
}
