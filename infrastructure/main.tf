terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = "terraform-state-mcp-rag-agent"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Shared Networking ---
module "vpc" {
  source = "./modules/networking"
  project_id = var.project_id
  vpc_name   = "mcp-agent-vpc"
  subnet_name = "mcp-agent-subnet"
}

# --- AI Platform (Vertex AI + Vector Search) ---
module "ai_platform" {
  source = "./modules/ai-platform"
  project_id = var.project_id
  region     = var.region
  vpc_network = module.vpc.network_id
  depends_on = [module.vpc]
}

# --- Compute (Cloud Run Services) ---
module "agent_service" {
  source = "./modules/compute"
  service_name = "mcp-agent"
  image_name   = "gcr.io/${var.project_id}/mcp-agent:latest"
  vpc_connector = module.vpc.vpc_access_connector
  env_vars = {
    PROJECT_ID = var.project_id
    VERTEX_AI_Endpoint = module.ai_platform.vector_search_endpoint
  }
}

module "mcp_server" {
  source = "./modules/compute"
  service_name = "mcp-tools"
  image_name   = "gcr.io/${var.project_id}/mcp-tools:latest"
  vpc_connector = module.vpc.vpc_access_connector
  allow_unauthenticated = false # Requires authentication from the Agent
}
