#!/bin/bash

# Test Runner Script for MCP + RAG + AI Agent Project
# Runs all tests across services

set -e

echo "🧪 MCP + RAG + AI Agent - Test Suite"
echo "====================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track test results
FAILED_TESTS=0

# Function to run tests for a service
run_service_tests() {
    local service_name=$1
    local service_path=$2
    
    echo -e "${YELLOW}Testing: ${service_name}${NC}"
    echo "----------------------------------------"
    
    cd "$service_path"
    
    # Install test dependencies
    if [ -f "requirements-test.txt" ]; then
        pip install -q -r requirements-test.txt
    fi
    
    # Install main dependencies
    if [ -f "requirements.txt" ]; then
        pip install -q -r requirements.txt
    fi
    
    # Run pytest
    if pytest -v --cov=. --cov-report=term-missing; then
        echo -e "${GREEN}✅ ${service_name} tests passed${NC}"
    else
        echo -e "${RED}❌ ${service_name} tests failed${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    echo ""
    cd - > /dev/null
}

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "📍 Project root: $PROJECT_ROOT"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "🔧 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install -q --upgrade pip

echo ""
echo "🚀 Running tests..."
echo ""

# Test MCP Server
if [ -d "src/mcp-server" ]; then
    run_service_tests "MCP Server" "src/mcp-server"
else
    echo -e "${YELLOW}⚠️  MCP Server directory not found${NC}"
fi

# Test Agent Service
if [ -d "src/agent-service" ]; then
    run_service_tests "Agent Service" "src/agent-service"
else
    echo -e "${YELLOW}⚠️  Agent Service directory not found${NC}"
fi

# Test RAG Pipeline
if [ -d "src/rag-pipeline" ] && [ -f "src/rag-pipeline/test_ingest.py" ]; then
    run_service_tests "RAG Pipeline" "src/rag-pipeline"
fi

# Summary
echo "======================================="
echo "📊 Test Summary"
echo "======================================="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED_TESTS test suite(s) failed${NC}"
    exit 1
fi
