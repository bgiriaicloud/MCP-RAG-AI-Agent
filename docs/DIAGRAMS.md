# Visual Architecture Diagrams

## Table of Contents
1. [System Overview](#system-overview)
2. [Data Flow](#data-flow)
3. [MCP Protocol Flow](#mcp-protocol-flow)
4. [RAG Pipeline](#rag-pipeline)
5. [Deployment Architecture](#deployment-architecture)
6. [Network Architecture](#network-architecture)

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              USER LAYER                                 │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │
│  │   Browser    │  │  IDE Plugin  │  │  Mobile App  │                │
│  │  (Web App)   │  │  (MCP Client)│  │   (Future)   │                │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                │
│         │                 │                  │                         │
└─────────┼─────────────────┼──────────────────┼─────────────────────────┘
          │                 │                  │
          │ HTTPS           │ MCP Protocol     │ HTTPS
          │                 │                  │
┌─────────▼─────────────────▼──────────────────▼─────────────────────────┐
│                         APPLICATION LAYER                               │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    AI AGENT SERVICE                             │  │
│  │                   (FastAPI + Gemini)                            │  │
│  │                                                                 │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │  │
│  │  │   Router     │  │ RAG Client   │  │ MCP Client   │         │  │
│  │  │   Logic      │  │              │  │              │         │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │  │
│  │         │                 │                  │                 │  │
│  │         └────────┬────────┴──────────────────┘                 │  │
│  │                  │                                              │  │
│  │         ┌────────▼────────┐                                    │  │
│  │         │  Gemini Engine  │                                    │  │
│  │         │   (Reasoning)   │                                    │  │
│  │         └─────────────────┘                                    │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────┬───────────────────────────┬───────────────────────────────────┘
          │                           │
          │                           │
┌─────────▼───────────┐     ┌─────────▼─────────────┐
│                     │     │                       │
│   MCP SERVER        │     │   RAG PIPELINE        │
│   (Tool Provider)   │     │   (Knowledge Base)    │
│                     │     │                       │
│  ┌──────────────┐  │     │  ┌────────────────┐  │
│  │ Tool Registry│  │     │  │ Vector Search  │  │
│  └──────┬───────┘  │     │  │   (Vertex AI)  │  │
│         │          │     │  └────────────────┘  │
│  ┌──────▼───────┐  │     │                       │
│  │ Tool Executor│  │     │  ┌────────────────┐  │
│  └──────────────┘  │     │  │  Embeddings    │  │
│                     │     │  │   Generator    │  │
│  Tools:             │     │  └────────────────┘  │
│  • GitHub API       │     │                       │
│  • Slack API        │     │  ┌────────────────┐  │
│  • Database Ops     │     │  │  Document      │  │
│  • File System      │     │  │  Storage (GCS) │  │
│  • Custom APIs      │     │  └────────────────┘  │
└─────────────────────┘     └───────────────────────┘
```

---

## Data Flow

### User Query Processing

```
┌──────────┐
│   User   │
│  Types   │
│  Query   │
└────┬─────┘
     │
     │ 1. "What's the tax on $100k income?"
     │
     ▼
┌─────────────────┐
│   Web App       │
│  (Next.js)      │
│                 │
│  POST /api/chat │
└────┬────────────┘
     │
     │ 2. Forward to Agent
     │
     ▼
┌──────────────────────────────────────────┐
│         AI Agent Service                 │
│                                          │
│  Step 1: Parse Query                    │
│  ┌────────────────────────────────────┐ │
│  │ "User wants tax calculation"       │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Step 2: Retrieve Context (RAG)        │
│  ┌────────────────────────────────────┐ │
│  │ Query Vector Search                │ │
│  │ → "Tax rates: US 20%, UK 25%..."  │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Step 3: Fetch Available Tools (MCP)   │
│  ┌────────────────────────────────────┐ │
│  │ GET /mcp/list_tools                │ │
│  │ → {calculate_tax, ...}             │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Step 4: Construct Prompt              │
│  ┌────────────────────────────────────┐ │
│  │ System: You are a helpful AI...   │ │
│  │ Context: Tax rates are...          │ │
│  │ Tools: calculate_tax(income, ...)  │ │
│  │ User: What's tax on $100k?         │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Step 5: Send to Gemini                │
│  ┌────────────────────────────────────┐ │
│  │ Gemini decides to use tool         │ │
│  │ → call calculate_tax(100000, "US") │ │
│  └────────────────────────────────────┘ │
└────┬─────────────────────────────────────┘
     │
     │ 6. Execute Tool
     │
     ▼
┌─────────────────┐
│   MCP Server    │
│                 │
│  POST /mcp/     │
│  call_tool      │
│                 │
│  calculate_tax( │
│    100000, "US")│
│                 │
│  → $20,000      │
└────┬────────────┘
     │
     │ 7. Return Result
     │
     ▼
┌──────────────────────────────────────────┐
│         AI Agent Service                 │
│                                          │
│  Step 8: Send Result to Gemini          │
│  ┌────────────────────────────────────┐ │
│  │ Tool result: $20,000               │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Step 9: Generate Final Response        │
│  ┌────────────────────────────────────┐ │
│  │ "The tax on $100,000 income in    │ │
│  │  the US is $20,000 (20% rate)."   │ │
│  └────────────────────────────────────┘ │
└────┬─────────────────────────────────────┘
     │
     │ 10. Return to User
     │
     ▼
┌─────────────────┐
│   Web App       │
│  Display Answer │
└─────────────────┘
```

---

## MCP Protocol Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    MCP CLIENT (Agent)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ 1. Discover Tools
                              │
                              ▼
                    ┌──────────────────┐
                    │ GET /mcp/        │
                    │ list_tools       │
                    └────────┬─────────┘
                             │
                             │ 2. Tool Definitions
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    MCP SERVER (Tools)                       │
│                                                             │
│  {                                                          │
│    "tools": {                                               │
│      "calculate_tax": {                                     │
│        "description": "Calculates tax...",                  │
│        "parameters": {                                      │
│          "income": {"type": "number"},                      │
│          "region": {"type": "string"}                       │
│        }                                                    │
│      },                                                     │
│      "fetch_stock_price": { ... }                           │
│    }                                                        │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
                             │
                             │ 3. Agent decides to use tool
                             │
                             ▼
                    ┌──────────────────┐
                    │ POST /mcp/       │
                    │ call_tool        │
                    │                  │
                    │ {                │
                    │   "tool_name":   │
                    │   "calculate_tax"│
                    │   "arguments": { │
                    │     "income":    │
                    │     100000       │
                    │   }              │
                    │ }                │
                    └────────┬─────────┘
                             │
                             │ 4. Execute Tool
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    MCP SERVER (Tools)                       │
│                                                             │
│  1. Validate parameters                                    │
│  2. Execute tool logic                                     │
│  3. Return result                                          │
│                                                             │
│  { "result": 20000 }                                       │
└─────────────────────────────────────────────────────────────┘
                             │
                             │ 5. Tool Result
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    MCP CLIENT (Agent)                       │
│                                                             │
│  Use result in final response generation                   │
└─────────────────────────────────────────────────────────────┘
```

---

## RAG Pipeline

### Ingestion Phase

```
┌──────────────────┐
│  Data Sources    │
│                  │
│  • PDFs          │
│  • Code Repos    │
│  • Databases     │
│  • APIs          │
└────────┬─────────┘
         │
         │ 1. Collect Documents
         │
         ▼
┌──────────────────┐
│  Preprocessing   │
│                  │
│  • Chunking      │
│  • Cleaning      │
│  • Metadata      │
└────────┬─────────┘
         │
         │ 2. Process
         │
         ▼
┌──────────────────────────┐
│  Embedding Generation    │
│  (Vertex AI)             │
│                          │
│  textembedding-gecko     │
│  → 768-dim vectors       │
└────────┬─────────────────┘
         │
         │ 3. Generate Embeddings
         │
         ▼
┌──────────────────┐
│  Cloud Storage   │
│  (GCS Bucket)    │
│                  │
│  embeddings.json │
└────────┬─────────┘
         │
         │ 4. Upload
         │
         ▼
┌──────────────────────────┐
│  Vertex AI Vector Search │
│  (Index)                 │
│                          │
│  • Build index           │
│  • Deploy to endpoint    │
└──────────────────────────┘
```

### Retrieval Phase

```
┌──────────────────┐
│  User Query      │
│  "What is MCP?"  │
└────────┬─────────┘
         │
         │ 1. Query
         │
         ▼
┌──────────────────────────┐
│  Embedding Generation    │
│  (Vertex AI)             │
│                          │
│  Query → 768-dim vector  │
└────────┬─────────────────┘
         │
         │ 2. Vectorize
         │
         ▼
┌──────────────────────────┐
│  Vertex AI Vector Search │
│  (Similarity Search)     │
│                          │
│  Find top-k similar docs │
└────────┬─────────────────┘
         │
         │ 3. Retrieve
         │
         ▼
┌──────────────────┐
│  Retrieved Docs  │
│                  │
│  1. MCP is...    │
│  2. Protocol...  │
│  3. Tools...     │
└────────┬─────────┘
         │
         │ 4. Context
         │
         ▼
┌──────────────────┐
│  AI Agent        │
│  (Use in prompt) │
└──────────────────┘
```

---

## Deployment Architecture (GCP)

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CLOUD LOAD BALANCER                        │
│                    (Global HTTPS LB)                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  Cloud Run    │  │  Cloud Run    │  │  Cloud Run    │
│  (Web App)    │  │  (Agent Svc)  │  │  (MCP Server) │
│               │  │               │  │               │
│  Next.js      │  │  FastAPI      │  │  FastAPI      │
│  Frontend     │  │  + Gemini     │  │  Tools        │
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                  │
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                           │ VPC Connector
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                          VPC NETWORK                            │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐ │
│  │  Secret Manager │  │  Cloud Storage  │  │  Vertex AI     │ │
│  │                 │  │                 │  │                │ │
│  │  • API Keys     │  │  • Documents    │  │  • Gemini      │ │
│  │  • Credentials  │  │  • Embeddings   │  │  • Embeddings  │ │
│  │                 │  │                 │  │  • Vector      │ │
│  └─────────────────┘  └─────────────────┘  │    Search      │ │
│                                             └────────────────┘ │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐                     │
│  │  Cloud Logging  │  │  Cloud          │                     │
│  │                 │  │  Monitoring     │                     │
│  └─────────────────┘  └─────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         PUBLIC INTERNET                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Port 443 (HTTPS)
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      CLOUD ARMOR (WAF)                          │
│                    • DDoS Protection                            │
│                    • Rate Limiting                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      VPC NETWORK                                │
│                    (mcp-agent-vpc)                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              SUBNET (us-central1)                        │  │
│  │              10.0.0.0/24                                 │  │
│  │                                                          │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │  │
│  │  │ Cloud Run   │  │ Cloud Run   │  │ Cloud Run   │    │  │
│  │  │ (Web App)   │  │ (Agent)     │  │ (MCP)       │    │  │
│  │  │             │  │             │  │             │    │  │
│  │  │ Public      │  │ Public      │  │ Private     │    │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         VPC ACCESS CONNECTOR                             │  │
│  │         10.8.0.0/28                                      │  │
│  │                                                          │  │
│  │  Allows Cloud Run → VPC communication                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         FIREWALL RULES                                   │  │
│  │                                                          │  │
│  │  • Allow HTTPS (443) from internet                      │  │
│  │  • Allow internal communication                         │  │
│  │  • Deny all other inbound                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         PRIVATE GOOGLE ACCESS                            │  │
│  │                                                          │  │
│  │  • Access to GCP APIs without public IP                 │  │
│  │  • Vertex AI, Cloud Storage, Secret Manager             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Security Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                      SECURITY LAYERS                            │
│                                                                 │
│  Layer 1: Network Security                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • VPC Isolation                                          │  │
│  │ • Firewall Rules                                         │  │
│  │ • Cloud Armor (DDoS, WAF)                                │  │
│  │ • Private Service Connect                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Layer 2: Identity & Access                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • Service Accounts (least privilege)                     │  │
│  │ • IAM Policies                                           │  │
│  │ • Workload Identity                                      │  │
│  │ • Cloud IAP (future)                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Layer 3: Data Security                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • Encryption at rest (default)                           │  │
│  │ • Encryption in transit (TLS)                            │  │
│  │ • Secret Manager for credentials                         │  │
│  │ • VPC Service Controls (optional)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Layer 4: Application Security                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • Input validation                                       │  │
│  │ • Rate limiting                                          │  │
│  │ • Authentication (future)                                │  │
│  │ • Audit logging                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Layer 5: Monitoring & Response                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • Cloud Logging                                          │  │
│  │ • Cloud Monitoring                                       │  │
│  │ • Security Command Center                                │  │
│  │ • Alerting & Incident Response                           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## CI/CD Pipeline

```
┌──────────────┐
│   GitHub     │
│  Repository  │
└──────┬───────┘
       │
       │ git push
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│                    CLOUD BUILD                           │
│                                                          │
│  Step 1: Build Docker Images                            │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • docker build mcp-server                          │ │
│  │ • docker build agent-service                       │ │
│  │ • docker build web-app                             │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Step 2: Push to Container Registry                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • gcr.io/project/mcp-server:$SHA                   │ │
│  │ • gcr.io/project/agent-service:$SHA                │ │
│  │ • gcr.io/project/web-app:$SHA                      │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Step 3: Deploy to Cloud Run                            │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • gcloud run deploy mcp-server                     │ │
│  │ • gcloud run deploy agent-service                  │ │
│  │ • gcloud run deploy web-app                        │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Step 4: Run Tests (optional)                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │ • Integration tests                                │ │
│  │ • Smoke tests                                      │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
       │
       │ Deployment complete
       │
       ▼
┌──────────────────┐
│  Production      │
│  Environment     │
└──────────────────┘
```

---

*These diagrams provide a visual understanding of the MCP + RAG + AI Agent architecture on GCP.*
