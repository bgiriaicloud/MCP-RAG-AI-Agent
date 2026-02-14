# MCP + RAG + AI Agent Architecture

> **Production-grade implementation combining Model Context Protocol, Retrieval-Augmented Generation, and AI Agents on Google Cloud Platform**

[![Status](https://img.shields.io/badge/status-production--ready-green)]()
[![GCP](https://img.shields.io/badge/platform-GCP-blue)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()

## 🎯 What Is This?

This project provides a **complete, enterprise-ready implementation** of a modern AI system that combines:

- **🔌 MCP (Model Context Protocol)**: Standardized tool access for LLMs
- **📚 RAG (Retrieval-Augmented Generation)**: Knowledge-enhanced AI responses
- **🤖 AI Agents**: Autonomous task orchestration with Gemini

All deployed on **Google Cloud Platform** following best practices for security, scalability, and observability.

## ✨ Key Features

- ✅ **Production-Ready**: Enterprise-grade architecture
- ✅ **Fully Tested**: Comprehensive test coverage
- ✅ **Well-Documented**: Detailed guides and diagrams
- ✅ **GCP Best Practices**: Security, scalability, observability
- ✅ **Modern Stack**: Latest technologies and frameworks
- ✅ **Extensible**: Easy to add new tools and features
- ✅ **Cost-Optimized**: Serverless, pay-per-use model
- ✅ **DevOps Ready**: GitHub Actions, Cloud Build, IaC, monitoring included

## 🚀 Quick Start

### 1. Validate Project Structure

```bash
./validate_structure.sh
```

This ensures all required files are in place.

### 2. Local Development

```bash
# Set up environment
cp .env.example .env
# Edit .env with your GCP project details

# Start all services
./quickstart.sh

# Access the application
# Web App: http://localhost:3000
# Agent Service: http://localhost:8000
# MCP Server: http://localhost:8080
```

### 3. Run Tests

```bash
# Unit tests
./run_tests.sh

# Integration tests
./test_integration.sh
```

### 4. Deploy to GCP

```bash
# Option 1: Cloud Build (Recommended)
gcloud builds submit --config cloudbuild.yaml .

# Option 2: Terraform
cd infrastructure
terraform init
terraform apply
```

## 📁 Project Structure

```
mcp-rag-ai-agent/
├── src/
│   ├── agent-service/      # AI Agent orchestrator (FastAPI + Gemini)
│   ├── mcp-server/         # MCP tool server (FastAPI)
│   ├── rag-pipeline/       # RAG ingestion pipeline (Vertex AI)
│   └── web-app/            # Next.js frontend
├── infrastructure/         # Terraform IaC for GCP
│   ├── modules/
│   │   ├── networking/     # VPC, subnets, connectors
│   │   ├── compute/        # Cloud Run services
│   │   └── ai-platform/    # Vertex AI setup
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── docs/
│   ├── ARCHITECTURE.md     # System architecture details
│   ├── DEPLOYMENT.md       # Deployment guide
│   ├── TESTING.md          # Testing guide
│   └── DIAGRAMS.md         # Visual diagrams
├── docker-compose.yml      # Local development
├── cloudbuild.yaml         # CI/CD pipeline
├── quickstart.sh           # Quick start script
├── run_tests.sh            # Test runner
├── test_integration.sh     # Integration tests
└── validate_structure.sh   # Structure validator
```

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                          │
│                    (Next.js Web App)                            │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AI Agent Service                           │
│                   (FastAPI + Gemini)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Query      │  │     RAG      │  │     MCP      │         │
│  │  Processor   │  │  Retrieval   │  │   Client     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└───────┬────────────────────┬────────────────────┬──────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌──────────────┐
│   Gemini     │   │  Vertex AI       │   │ MCP Server   │
│   3.0 Pro    │   │  Vector Search   │   │  (Tools)     │
└──────────────┘   └──────────────────┘   └──────────────┘
```

See [docs/DIAGRAMS.md](docs/DIAGRAMS.md) for detailed visual diagrams.

## 🛠️ Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **LLM** | Gemini 3.0 Pro | Reasoning & generation |
| **Vector DB** | Vertex AI Vector Search | Semantic search |
| **Embeddings** | textembedding-gecko@003 | Document encoding |
| **Agent Framework** | FastAPI + Vertex AI SDK | Orchestration |
| **MCP** | FastAPI | Tool protocol |
| **Frontend** | Next.js 14 + TypeScript | User interface |
| **Infrastructure** | Terraform | IaC |
| **CI/CD** | GitHub Actions / Cloud Build | Automation |
| **Compute** | Cloud Run | Serverless |
| **Storage** | Cloud Storage | Documents |
| **Networking** | VPC + Connector | Security |

## 📚 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Detailed system architecture and design decisions
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)**: Step-by-step deployment guide
- **[TESTING.md](docs/TESTING.md)**: Testing strategies and examples
- **[DIAGRAMS.md](docs/DIAGRAMS.md)**: Visual architecture diagrams
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)**: Complete project summary

## 🧪 Testing

### Unit Tests
```bash
./run_tests.sh
```

Tests individual components:
- MCP Server endpoints
- Agent Service logic
- Tool execution
- Request/response validation

### Integration Tests
```bash
./test_integration.sh
```

Tests the complete system:
- Service communication
- End-to-end workflows
- Docker Compose setup

### Manual Testing
```bash
# Test MCP Server
curl http://localhost:8080/mcp/list_tools

# Test Agent Service
curl -X POST http://localhost:8000/agent/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "What tools are available?"}'
```

## 🔐 Security

- **VPC Isolation**: Private networking for services
- **IAM**: Least privilege service accounts
- **Secret Manager**: Secure credential storage
- **Encryption**: At rest and in transit
- **Audit Logging**: Complete audit trail
- **Cloud Armor**: DDoS and WAF protection

## 📈 Scalability

- **Cloud Run**: Auto-scales from 0 to N instances
- **Vector Search**: Handles millions of embeddings
- **Stateless Design**: Horizontal scaling enabled
- **Multi-Region**: Deploy across regions
- **CDN**: Cloud CDN for static assets

## 💰 Cost Optimization

- **Scale to Zero**: Cloud Run only charges for active requests
- **Efficient Embeddings**: Batch processing
- **Resource Limits**: Prevent runaway costs
- **Regional Deployment**: Reduce egress charges

## 🎓 Learn More

### Understanding the Components
- [Model Context Protocol](https://modelcontextprotocol.io)
- [Vertex AI Vector Search](https://cloud.google.com/vertex-ai/docs/vector-search)
- [Vertex AI Gemini](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/gemini)

### GCP Resources
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform on GCP](https://cloud.google.com/docs/terraform)
- [Cloud Build](https://cloud.google.com/build/docs)

## 🤝 Contributing

1. Follow the existing code structure
2. Add tests for new features
3. Update documentation
4. Run tests before committing
5. Use conventional commits

## 📝 License

MIT License - see LICENSE file for details

## 🙋 Support

- Check the [documentation](docs/)
- Review the [testing guide](docs/TESTING.md)
- Validate your setup: `./validate_structure.sh`
- Check logs: `docker-compose logs -f`

---

**Built with ❤️ using GCP Best Practices**
