from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
import uvicorn
import logging

# Initialize FastAPI app
app = FastAPI(title="MCP Tools Server", description="Exposes tools via MCP protocol")

# Configure structured logging for Cloud Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ToolRequest(BaseModel):
    tool_name: str
    arguments: dict = Field(default_factory=dict)

# Define available tools
TOOLS = {
    "calculate_tax": {
        "description": "Calculates tax based on income and region",
        "parameters": {
            "income": {"type": "number", "description": "Annual income"},
            "region": {"type": "string", "description": "Tax region code (e.g., US, UK)"}
        }
    },
    "fetch_stock_price": {
        "description": "Fetches current stock price for a given symbol",
        "parameters": {
            "symbol": {"type": "string", "description": "Stock ticker symbol (e.g., AAPL)"}
        }
    }
}

@app.get("/mcp/list_tools")
async def list_tools():
    """Lists available tools for the Agent to discover."""
    logger.info("Listing tools")
    return {"tools": TOOLS}

@app.post("/mcp/call_tool")
async def call_tool(request: ToolRequest):
    """Executes a tool call requested by the Agent."""
    tool_name = request.tool_name
    args = request.arguments
    
    logger.info(f"Tool call received: {tool_name} with args: {args}")

    if tool_name == "calculate_tax":
        income = args.get("income", 0)
        tax = income * 0.2  # 20% flat tax for example
        return {"result": tax}
    
    elif tool_name == "fetch_stock_price":
        return {"result": 150.00, "currency": "USD"}
    
    else:
        return JSONResponse(status_code=404, content={"error": "Tool not found"})

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
