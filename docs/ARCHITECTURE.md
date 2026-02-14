# Architecture Documentation

## System Overview

This project implements a production-grade AI system that combines three powerful paradigms:

1. **Model Context Protocol (MCP)**: Standardized tool access for LLMs
2. **Retrieval-Augmented Generation (RAG)**: Knowledge-enhanced responses
3. **AI Agents**: Autonomous task orchestration

## Architecture Diagram

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
        │                    │                    │ MCP Protocol
        ▼                    ▼                    ▼
┌──────────────┐   ┌──────────────────┐   ┌──────────────┐
│   Gemini     │   │  Vertex AI       │   │ MCP Server   │
│   3.0 Pro    │   │  Vector Search   │   │  (Tools)     │
└──────────────┘   └──────────────────┘   └──────────────┘
```

## Component Details

### 1. Web Application (Next.js)
- **Purpose**: User-facing chat interface
- **Technology**: Next.js 14, React, TypeScript, Tailwind CSS
- **Deployment**: Cloud Run
- **Key Features**:
  - Real-time chat interface
  - Streaming responses (future enhancement)
  - Session management
  - Responsive design

### 2. AI Agent Service
- **Purpose**: Orchestrates RAG retrieval and MCP tool execution
- **Technology**: FastAPI, Vertex AI SDK, Python 3.9+
- **Deployment**: Cloud Run with VPC connector
- **Key Responsibilities**:
  - Query understanding and routing
  - RAG context retrieval
  - MCP tool discovery and invocation
  - Response generation via Gemini

**Flow**:
```python
1. Receive user query
2. Retrieve relevant context from Vector Search (RAG)
3. Fetch available tools from MCP Server
4. Construct enhanced prompt with context + tools
5. Send to Gemini with function calling enabled
6. Execute tool calls if needed
7. Return final response
```

### 3. MCP Server
- **Purpose**: Exposes domain-specific tools via standardized protocol
- **Technology**: FastAPI, Python
- **Deployment**: Cloud Run (private, no public access)
- **Protocol Endpoints**:
  - `GET /mcp/list_tools`: Returns available tools and schemas
  - `POST /mcp/call_tool`: Executes a specific tool

**Example Tools**:
- `calculate_tax`: Financial calculations
- `fetch_stock_price`: Market data retrieval
- Custom tools can be added easily

### 4. RAG Pipeline
- **Purpose**: Ingest documents and enable semantic search
- **Technology**: Vertex AI Embeddings, Vector Search
- **Components**:
  - **Ingestion**: Converts documents to embeddings
  - **Storage**: GCS bucket for raw data
  - **Index**: Vertex AI Vector Search index
  - **Retrieval**: Similarity search at query time

**Ingestion Flow**:
```
Documents → Chunking → Embedding (textembedding-gecko) 
         → Upload to GCS → Update Vector Search Index
```

## Data Flow

### User Query Processing

```
1. User submits query via Web App
   ↓
2. Web App → Agent Service API (/agent/chat)
   ↓
3. Agent Service:
   a. Queries Vector Search for relevant context
   b. Fetches available tools from MCP Server
   c. Constructs prompt: system instruction + RAG context + user query
   d. Sends to Gemini with tool definitions
   ↓
4. Gemini processes and may request tool execution
   ↓
5. If tool needed:
   Agent Service → MCP Server (/mcp/call_tool)
   ↓
6. MCP Server executes tool and returns result
   ↓
7. Agent Service sends tool result back to Gemini
   ↓
8. Gemini generates final response
   ↓
9. Response returned to Web App
   ↓
10. User sees answer
```

## GCP Best Practices Implemented

### 1. Security
- **Service Accounts**: Each service has minimal required permissions
- **Secret Manager**: API keys and sensitive data stored securely
- **VPC**: Private communication between services
- **IAM**: Principle of least privilege
- **No Public Access**: MCP Server requires authentication

### 2. Scalability
- **Cloud Run**: Serverless, auto-scales to zero
- **Vector Search**: Handles millions of embeddings
- **Stateless Design**: Horizontal scaling enabled
- **Caching**: (Future) Cloud Memorystore for frequent queries

### 3. Observability
- **Cloud Logging**: Structured JSON logs
- **Cloud Trace**: Distributed tracing
- **Cloud Monitoring**: Custom metrics and alerts
- **Error Reporting**: Automatic error aggregation

### 4. Cost Optimization
- **Scale to Zero**: Cloud Run only charges for active requests
- **Efficient Embeddings**: Batch processing for ingestion
- **Resource Limits**: CPU/Memory constraints prevent runaway costs
- **Regional Deployment**: Single region (us-central1) reduces egress

### 5. Reliability
- **Health Checks**: Kubernetes-style probes
- **Graceful Degradation**: Fallback responses if tools fail
- **Retry Logic**: Exponential backoff for transient failures
- **Multi-AZ**: Cloud Run automatically distributes across zones

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| LLM | Gemini 3.0 Pro | Reasoning and generation |
| Vector DB | Vertex AI Vector Search | Semantic search |
| Embeddings | textembedding-gecko@003 | Document encoding |
| Agent Framework | FastAPI + Vertex AI SDK | Orchestration |
| MCP Implementation | FastAPI | Tool protocol |
| Frontend | Next.js 14 + TypeScript | User interface |
| Infrastructure | Terraform | IaC |
| CI/CD | Cloud Build | Deployment automation |
| Compute | Cloud Run | Serverless containers |
| Storage | Cloud Storage | Document storage |
| Networking | VPC + Connector | Private communication |

## Extension Points

### Adding New MCP Tools
1. Define tool schema in `src/mcp-server/main.py`
2. Implement tool logic
3. Redeploy MCP Server
4. Agent automatically discovers new tools

### Adding Documents to RAG
1. Upload documents to GCS
2. Run ingestion script: `python src/rag-pipeline/ingest.py`
3. Vector Search index updates automatically

### Customizing the Agent
- Modify system instructions in `src/agent-service/main.py`
- Add custom routing logic
- Implement multi-turn conversations

## Performance Considerations

- **Cold Start**: Cloud Run ~1-3s (mitigated with min instances)
- **RAG Retrieval**: ~100-200ms for vector search
- **Gemini Latency**: ~1-3s depending on prompt complexity
- **MCP Tool Calls**: ~50-100ms per tool
- **End-to-End**: Typically 2-5s for simple queries

## Future Enhancements

1. **Streaming Responses**: Real-time token streaming
2. **Multi-Modal**: Image and document understanding
3. **Agent Memory**: Conversation history with Firestore
4. **Advanced RAG**: Hybrid search (vector + keyword)
5. **Monitoring Dashboard**: Custom metrics visualization
6. **A/B Testing**: Multiple agent configurations
7. **Rate Limiting**: API quota management
