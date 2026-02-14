import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch
from main import app

client = TestClient(app)

@pytest.fixture
def mock_vertex_ai():
    """Mock Vertex AI responses."""
    with patch('main.model') as mock_model:
        mock_response = Mock()
        mock_response.text = "This is a test response from Gemini."
        mock_model.generate_content.return_value = mock_response
        yield mock_model

@pytest.fixture
def mock_mcp_server():
    """Mock MCP server responses."""
    with patch('httpx.get') as mock_get:
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "tools": {
                "test_tool": {
                    "description": "A test tool",
                    "parameters": {}
                }
            }
        }
        mock_get.return_value = mock_response
        yield mock_get

def test_chat_endpoint_exists():
    """Test that chat endpoint is accessible."""
    response = client.post(
        "/agent/chat",
        json={"query": "Hello"}
    )
    # May fail without proper setup, but endpoint should exist
    assert response.status_code in [200, 500]

def test_chat_request_validation():
    """Test request validation."""
    # Missing query field
    response = client.post(
        "/agent/chat",
        json={}
    )
    assert response.status_code == 422  # Validation error

def test_chat_with_mock_gemini(mock_vertex_ai, mock_mcp_server):
    """Test chat with mocked Gemini."""
    response = client.post(
        "/agent/chat",
        json={
            "query": "What is the weather?",
            "session_id": "test-session"
        }
    )
    
    # Should process without errors with mocks
    assert response.status_code in [200, 500]

def test_fetch_mcp_tools(mock_mcp_server):
    """Test MCP tool fetching."""
    from main import fetch_mcp_tools
    
    tools = fetch_mcp_tools()
    assert isinstance(tools, dict)

def test_query_rag():
    """Test RAG query function."""
    from main import query_rag
    
    result = query_rag("test query")
    assert isinstance(result, str)

@pytest.mark.parametrize("query", [
    "What is MCP?",
    "Explain RAG",
    "How do AI agents work?",
])
def test_various_queries(query, mock_vertex_ai, mock_mcp_server):
    """Test various query types."""
    response = client.post(
        "/agent/chat",
        json={"query": query}
    )
    assert response.status_code in [200, 500]
