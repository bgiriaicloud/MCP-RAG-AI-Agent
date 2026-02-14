from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import vertexai
from vertexai.generative_models import GenerativeModel, Tool, FunctionDeclaration
import logging
import httpx
import os

# Initialize FastAPI for the Agent Service
app = FastAPI(title="AI Agent Service", description="Orchestrates RAG & MCP Tools via Gemini")
logger = logging.getLogger("uvicorn.error")

# --- Configuration ---
PROJECT_ID = os.getenv("PROJECT_ID", "your-project-id")
LOCATION = os.getenv("LOCATION", "us-central1")
MCP_SERVER_URL = os.getenv("MCP_SERVER_URL", "http://mcp-server:8080")
RAG_ENDPOINT_ID = os.getenv("RAG_ENDPOINT_ID", "endpoint-id")

vertexai.init(project=PROJECT_ID, location=LOCATION)

# --- Define Gemini Model ---
# Using Gemini 3.0 Pro - Latest and most capable model (Released Nov 2025)
model = GenerativeModel("gemini-3.0-pro")

class ChatRequest(BaseModel):
    query: str
    session_id: str = "default-session"

def fetch_mcp_tools():
    """Dynamically fetches tools from the MCP Server."""
    try:
        response = httpx.get(f"{MCP_SERVER_URL}/mcp/list_tools")
        if response.status_code == 200:
            return response.json().get("tools", {})
        else:
            logger.error(f"Failed to fetch MCP tools: {response.text}")
            return {}
    except Exception as e:
        logger.error(f"MCP Server connection error: {e}")
        return {}

def query_rag(query_text: str):
    """Queries the RAG pipeline (Vertex AI Vector Search)."""
    # This would call the Vector Search Match Service
    # match_service_client = aiplatform_v1.MatchServiceClient(...)
    
    # Placeholder for retrieval
    logger.info(f"Retrieving context for query: {query_text}")
    return "Retrieved context from documents..."

@app.post("/agent/chat")
async def chat(request: ChatRequest):
    """
    Main entry point for user interaction.
    1. Fetches available tools from MCP.
    2. Retrieves relevant context from RAG.
    3. Prompts Gemini with RAG context + Tools.
    4. Returns final answer.
    """
    user_query = request.query
    
    # 1. Fetch available tools (dynamic tool loading)
    mcp_tools = fetch_mcp_tools()
    
    # 2. Retrieve Context (RAG)
    rag_context = query_rag(user_query)
    
    # Construction of prompt with context
    system_instruction = f"""
    You are a helpful AI assistant. 
    Use the provided context to answer questions.
    You have access to tools via the MCP (Model Context Protocol).
    
    Context: {rag_context}
    
    Available Tools: {mcp_tools}
    """
    
    # In a real implementation, you would convert `mcp_tools` into 
    # `FunctionDeclaration` objects for Gemini function calling.
    
    # 3. Generate Content
    try:
        response = model.generate_content(
            contents=[system_instruction, user_query],
            # tools=[Tool(function_declarations=...)] # If implementing actual function calling
        )
        return {"response": response.text}
    except Exception as e:
        logger.error(f"Gemini generation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
