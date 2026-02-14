# MCP + RAG + AI Agent - Deployment Guide

## Prerequisites

1. **GCP Project Setup**
   ```bash
   export PROJECT_ID="your-gcp-project-id"
   gcloud config set project $PROJECT_ID
   ```

2. **Enable Required APIs**
   ```bash
   gcloud services enable \
     run.googleapis.com \
     cloudbuild.googleapis.com \
     aiplatform.googleapis.com \
     compute.googleapis.com \
     storage-api.googleapis.com
   ```

3. **Authentication**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

## Local Development

### 1. Setup Environment
```bash
cp .env.example .env
# Edit .env with your GCP project details
```

### 2. Run with Docker Compose
```bash
docker-compose up --build
```

Access the application:
- **Web App**: http://localhost:3000
- **Agent Service**: http://localhost:8000
- **MCP Server**: http://localhost:8080

### 3. Test MCP Server
```bash
curl http://localhost:8080/mcp/list_tools
```

## Cloud Deployment

### Option 2: Using GitHub Actions (Highly Recommended for Production)

This project includes a pre-configured GitHub Actions workflow in `.github/workflows/deploy.yml`.

#### 1. Configure GCP Workload Identity Federation (WIF)
For secure authentication without long-lived keys:
1. Create a Workload Identity Pool and Provider.
2. Connect your GitHub repository to the Provider.
3. Grant the Service Account permissions to manage Cloud Run and Artifact Registry.

#### 2. Configure GitHub Secrets
Add the following secrets to your GitHub repository (**Settings > Secrets and variables > Actions**):
- `GCP_PROJECT_ID`: Your Google Cloud Project ID.
- `GCP_WIF_PROVIDER`: Full path to the WIF Provider (e.g., `projects/123/locations/global/workloadIdentityPools/my-pool/providers/my-gh-provider`).
- `GCP_WIF_SERVICE_ACCOUNT`: The email of the service account used for deployment.

#### 3. Trigger Deployment
Push to the `main` branch to trigger an automatic deployment:
```bash
git add .
git commit -m "feat: setup github actions deployment"
git push origin main
```

The workflow will:
1. Authenticate with GCP.
2. Build and push Docker images for all three services.
3. Deploy to Cloud Run.
4. Automatically wire the service URLs (MCP -> Agent -> Web App).

### Option 3: Manual Deployment (CLI)

#### Deploy MCP Server
```bash
cd src/mcp-server
gcloud builds submit --tag gcr.io/$PROJECT_ID/mcp-tools
gcloud run deploy mcp-tools \
  --image gcr.io/$PROJECT_ID/mcp-tools \
  --region us-central1 \
  --platform managed \
  --no-allow-unauthenticated
```

#### Deploy Agent Service
```bash
cd src/agent-service
gcloud builds submit --tag gcr.io/$PROJECT_ID/mcp-agent
gcloud run deploy mcp-agent \
  --image gcr.io/$PROJECT_ID/mcp-agent \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars PROJECT_ID=$PROJECT_ID,MCP_SERVER_URL=<MCP_SERVER_URL>
```

#### Deploy Web App
```bash
cd src/web-app
gcloud builds submit --tag gcr.io/$PROJECT_ID/mcp-web-app
gcloud run deploy mcp-web-app \
  --image gcr.io/$PROJECT_ID/mcp-web-app \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars AGENT_SERVICE_URL=<AGENT_SERVICE_URL>
```

### Option 4: Infrastructure as Code (Terraform)

1. **Initialize Terraform**
   ```bash
   cd infrastructure
   terraform init
   ```

2. **Create terraform.tfvars**
   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-central1"
   environment = "prod"
   ```

3. **Plan and Apply**
   ```bash
   terraform plan
   terraform apply
   ```

## Setting Up RAG Pipeline

### 1. Create Vector Search Index

```bash
# Create a GCS bucket for embeddings
gsutil mb -l us-central1 gs://$PROJECT_ID-vector-search-data

# Run the ingestion script
cd src/rag-pipeline
python ingest.py --docs "Document 1" "Document 2" "Document 3"
```

### 2. Create Index and Endpoint (via gcloud)

```bash
# This is a simplified example - actual implementation requires more configuration
gcloud ai indexes create \
  --display-name=rag-index \
  --region=us-central1 \
  --metadata-file=index-metadata.json
```

## Monitoring and Observability

### View Logs
```bash
# Agent Service logs
gcloud run services logs read mcp-agent --region us-central1

# MCP Server logs
gcloud run services logs read mcp-tools --region us-central1
```

### Cloud Trace
Access traces in the GCP Console: **Operations > Trace**

## Security Best Practices

1. **Service-to-Service Authentication**
   - MCP Server requires authentication (no public access)
   - Agent Service uses service account to call MCP Server

2. **Secret Management**
   ```bash
   echo -n "your-secret" | gcloud secrets create my-secret --data-file=-
   ```

3. **VPC Configuration**
   - Services communicate via VPC Access Connector
   - Private IP ranges for internal traffic

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   gcloud auth application-default login
   ```

2. **Service Not Responding**
   - Check Cloud Run logs
   - Verify environment variables
   - Ensure VPC connector is properly configured

3. **MCP Tools Not Available**
   - Verify MCP Server is deployed and healthy
   - Check service URL configuration in Agent Service

## Cost Optimization

- Use Cloud Run's autoscaling (scales to zero)
- Set appropriate CPU and memory limits
- Use Cloud Storage lifecycle policies for RAG data
- Monitor usage with Cloud Billing reports

## Next Steps

1. Customize MCP tools in `src/mcp-server/main.py`
2. Add more documents to RAG pipeline
3. Enhance the frontend UI
4. Implement authentication for the web app
5. Set up CI/CD with Cloud Build triggers
