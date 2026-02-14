# Testing Guide

## Overview

This project includes comprehensive testing at multiple levels:

1. **Unit Tests**: Test individual components in isolation
2. **Integration Tests**: Test services working together
3. **End-to-End Tests**: Test the complete system

## Prerequisites

- Python 3.9+
- Docker and Docker Compose
- Virtual environment (recommended)

## Running Tests

### Quick Test (All Services)

```bash
chmod +x run_tests.sh
./run_tests.sh
```

This will:
- Create a virtual environment
- Install dependencies
- Run unit tests for all services
- Generate coverage reports

### Integration Tests

```bash
chmod +x test_integration.sh
./test_integration.sh
```

This will:
- Start all services with Docker Compose
- Test MCP Server endpoints
- Test MCP tool execution
- Test Agent Service accessibility
- Test Web App availability
- Check logs for errors

### Individual Service Tests

#### MCP Server Tests

```bash
cd src/mcp-server
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt -r requirements-test.txt
pytest -v --cov=. --cov-report=html
```

#### Agent Service Tests

```bash
cd src/agent-service
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt -r requirements-test.txt
pytest -v --cov=. --cov-report=html
```

## Test Coverage

### MCP Server Tests

- ✅ Tool listing endpoint
- ✅ Tool execution endpoint
- ✅ Error handling for unknown tools
- ✅ Parameter validation
- ✅ Response format validation

### Agent Service Tests

- ✅ Chat endpoint validation
- ✅ Request/response format
- ✅ MCP tool fetching
- ✅ RAG query execution
- ✅ Gemini integration (mocked)

### Integration Tests

- ✅ Service startup and health
- ✅ MCP Server → Agent Service communication
- ✅ Tool execution flow
- ✅ Web App → Agent Service communication

## Manual Testing

### Test MCP Server Locally

```bash
# Start MCP Server
cd src/mcp-server
uvicorn main:app --reload --port 8080

# In another terminal, test endpoints
curl http://localhost:8080/mcp/list_tools

curl -X POST http://localhost:8080/mcp/call_tool \
  -H "Content-Type: application/json" \
  -d '{"tool_name": "calculate_tax", "arguments": {"income": 100000, "region": "US"}}'
```

### Test Agent Service Locally

```bash
# Set environment variables
export PROJECT_ID=your-project-id
export MCP_SERVER_URL=http://localhost:8080

# Start Agent Service
cd src/agent-service
uvicorn main:app --reload --port 8000

# Test chat endpoint
curl -X POST http://localhost:8000/agent/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "What tools are available?"}'
```

### Test Web App Locally

```bash
cd src/web-app
npm install
npm run dev

# Open browser to http://localhost:3000
```

## Docker Compose Testing

```bash
# Start all services
docker-compose up --build

# Test in browser
open http://localhost:3000

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## CI/CD Testing

### GitHub Actions (Example)

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: ./run_tests.sh
```

### Cloud Build Testing

```yaml
steps:
  - name: 'python:3.9'
    entrypoint: bash
    args: ['./run_tests.sh']
```

## Test Data

### Sample MCP Tool Calls

```json
{
  "tool_name": "calculate_tax",
  "arguments": {
    "income": 100000,
    "region": "US"
  }
}
```

```json
{
  "tool_name": "fetch_stock_price",
  "arguments": {
    "symbol": "AAPL"
  }
}
```

### Sample Agent Queries

```json
{
  "query": "What is the current tax rate for $100,000 income?",
  "session_id": "test-session-123"
}
```

## Troubleshooting

### Tests Failing

1. **Import Errors**: Ensure all dependencies are installed
   ```bash
   pip install -r requirements.txt -r requirements-test.txt
   ```

2. **Port Already in Use**: Kill existing processes
   ```bash
   lsof -ti:8080 | xargs kill -9
   lsof -ti:8000 | xargs kill -9
   ```

3. **Docker Issues**: Clean up containers
   ```bash
   docker-compose down -v
   docker system prune -f
   ```

### Integration Tests Failing

1. **Services Not Ready**: Increase wait time in `test_integration.sh`
2. **Network Issues**: Check Docker network configuration
3. **GCP Credentials**: Some tests may require valid GCP credentials

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test MCP Server
ab -n 1000 -c 10 http://localhost:8080/mcp/list_tools

# Test Agent Service
ab -n 100 -c 5 -p query.json -T application/json \
  http://localhost:8000/agent/chat
```

### Stress Testing with Locust

```python
# locustfile.py
from locust import HttpUser, task, between

class AgentUser(HttpUser):
    wait_time = between(1, 3)
    
    @task
    def chat(self):
        self.client.post("/agent/chat", json={
            "query": "Test query",
            "session_id": "load-test"
        })
```

Run: `locust -f locustfile.py --host=http://localhost:8000`

## Best Practices

1. **Run tests before commits**: `./run_tests.sh`
2. **Test in isolation**: Use mocks for external dependencies
3. **Test edge cases**: Empty inputs, invalid data, timeouts
4. **Monitor coverage**: Aim for >80% code coverage
5. **Integration tests**: Test real service interactions
6. **Performance tests**: Ensure scalability

## Continuous Improvement

- Add more test cases as features are added
- Update mocks when external APIs change
- Monitor test execution time
- Keep test dependencies up to date
- Document new test scenarios
