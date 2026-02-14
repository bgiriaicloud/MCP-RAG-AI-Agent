#!/bin/bash

# Project Structure Validator
# Validates that all required files and directories exist

set -e

echo "🔍 Project Structure Validation"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

# Function to check if file exists
check_file() {
    local file=$1
    local required=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $file"
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌${NC} $file (REQUIRED)"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${YELLOW}⚠️${NC}  $file (optional)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# Function to check if directory exists
check_dir() {
    local dir=$1
    local required=$2
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅${NC} $dir/"
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌${NC} $dir/ (REQUIRED)"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${YELLOW}⚠️${NC}  $dir/ (optional)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

echo "📁 Root Files"
echo "-------------"
check_file "README.md" "true"
check_file ".gitignore" "true"
check_file ".env.example" "true"
check_file "docker-compose.yml" "true"
check_file "cloudbuild.yaml" "true"
check_file "quickstart.sh" "true"
check_file "run_tests.sh" "true"
check_file "test_integration.sh" "true"
check_file "GEMINI_VERSION_INFO.md" "true"
check_dir ".github" "true"
check_file ".github/workflows/deploy.yml" "true"

echo ""
echo "📁 Documentation"
echo "----------------"
check_dir "docs" "true"
check_file "docs/ARCHITECTURE.md" "true"
check_file "docs/DEPLOYMENT.md" "true"
check_file "docs/TESTING.md" "true"

echo ""
echo "📁 Infrastructure"
echo "-----------------"
check_dir "infrastructure" "true"
check_file "infrastructure/main.tf" "true"
check_file "infrastructure/variables.tf" "true"
check_file "infrastructure/outputs.tf" "true"
check_dir "infrastructure/modules" "true"
check_dir "infrastructure/modules/networking" "true"
check_dir "infrastructure/modules/compute" "true"
check_dir "infrastructure/modules/ai-platform" "true"

echo ""
echo "📁 MCP Server"
echo "-------------"
check_dir "src/mcp-server" "true"
check_file "src/mcp-server/main.py" "true"
check_file "src/mcp-server/Dockerfile" "true"
check_file "src/mcp-server/requirements.txt" "true"
check_file "src/mcp-server/requirements-test.txt" "true"
check_file "src/mcp-server/test_main.py" "true"

echo ""
echo "📁 Agent Service"
echo "----------------"
check_dir "src/agent-service" "true"
check_file "src/agent-service/main.py" "true"
check_file "src/agent-service/Dockerfile" "true"
check_file "src/agent-service/requirements.txt" "true"
check_file "src/agent-service/requirements-test.txt" "true"
check_file "src/agent-service/test_main.py" "true"

echo ""
echo "📁 RAG Pipeline"
echo "---------------"
check_dir "src/rag-pipeline" "true"
check_file "src/rag-pipeline/ingest.py" "true"
check_file "src/rag-pipeline/requirements.txt" "true"

echo ""
echo "📁 Web Application"
echo "------------------"
check_dir "src/web-app" "true"
check_file "src/web-app/package.json" "true"
check_file "src/web-app/Dockerfile" "true"
check_file "src/web-app/next.config.mjs" "true"
check_file "src/web-app/tsconfig.json" "true"
check_file "src/web-app/tailwind.config.ts" "true"
check_file "src/web-app/postcss.config.mjs" "true"
check_dir "src/web-app/app" "true"
check_file "src/web-app/app/page.tsx" "true"
check_file "src/web-app/app/layout.tsx" "true"
check_file "src/web-app/app/globals.css" "true"
check_dir "src/web-app/app/api" "true"
check_file "src/web-app/app/api/chat/route.ts" "true"

echo ""
echo "================================"
echo "📊 Validation Summary"
echo "================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Perfect! All required files and directories exist.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS optional files/directories missing.${NC}"
    echo -e "${GREEN}✅ All required files exist.${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS required files/directories missing.${NC}"
    echo -e "${YELLOW}⚠️  $WARNINGS optional files/directories missing.${NC}"
    echo ""
    echo "Please create the missing required files before proceeding."
    exit 1
fi
