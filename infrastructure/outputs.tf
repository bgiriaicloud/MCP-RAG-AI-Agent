output "agent_service_url" {
  description = "URL of the deployed Agent Service"
  value       = module.agent_service.service_url
}

output "mcp_server_url" {
  description = "URL of the deployed MCP Server"
  value       = module.mcp_server.service_url
}

output "vector_search_endpoint" {
  description = "Vertex AI Vector Search endpoint ID"
  value       = module.ai_platform.vector_search_endpoint
}
