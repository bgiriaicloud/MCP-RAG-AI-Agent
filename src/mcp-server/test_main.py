import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_list_tools():
    """Test that MCP server can list available tools."""
    response = client.get("/mcp/list_tools")
    assert response.status_code == 200
    data = response.json()
    assert "tools" in data
    assert "calculate_tax" in data["tools"]
    assert "fetch_stock_price" in data["tools"]

def test_list_tools_structure():
    """Test that tool definitions have required fields."""
    response = client.get("/mcp/list_tools")
    data = response.json()
    
    for tool_name, tool_def in data["tools"].items():
        assert "description" in tool_def
        assert "parameters" in tool_def

def test_call_tool_calculate_tax():
    """Test calculate_tax tool execution."""
    response = client.post(
        "/mcp/call_tool",
        json={
            "tool_name": "calculate_tax",
            "arguments": {
                "income": 100000,
                "region": "US"
            }
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "result" in data
    assert data["result"] == 20000  # 20% of 100000

def test_call_tool_fetch_stock_price():
    """Test fetch_stock_price tool execution."""
    response = client.post(
        "/mcp/call_tool",
        json={
            "tool_name": "fetch_stock_price",
            "arguments": {
                "symbol": "AAPL"
            }
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "result" in data
    assert "currency" in data

def test_call_tool_not_found():
    """Test calling non-existent tool."""
    response = client.post(
        "/mcp/call_tool",
        json={
            "tool_name": "nonexistent_tool",
            "arguments": {}
        }
    )
    assert response.status_code == 404
    data = response.json()
    assert "error" in data

def test_call_tool_missing_arguments():
    """Test calling tool with missing arguments."""
    response = client.post(
        "/mcp/call_tool",
        json={
            "tool_name": "calculate_tax",
            "arguments": {}
        }
    )
    assert response.status_code == 200
    # Should handle gracefully with defaults

def test_health_check():
    """Test basic health check."""
    response = client.get("/mcp/list_tools")
    assert response.status_code == 200
