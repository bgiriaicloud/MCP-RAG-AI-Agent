#!/bin/bash

# MCP + RAG + AI Agent - Quick Start Script
# This script helps you get started with local development

set -e

echo "🚀 MCP + RAG + AI Agent - Quick Start"
echo "======================================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop."
    exit 1
fi

if ! command -v gcloud &> /dev/null; then
    echo "⚠️  gcloud CLI is not installed. Some features may not work."
    echo "   Install from: https://cloud.google.com/sdk/docs/install"
fi

echo "✅ Prerequisites check complete"
echo ""

# Setup environment
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your GCP project details"
    echo ""
fi

# Authenticate with GCP (if gcloud is available)
if command -v gcloud &> /dev/null; then
    echo "🔐 GCP Authentication"
    read -p "Do you want to authenticate with GCP now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gcloud auth application-default login
        echo "✅ Authentication complete"
    fi
    echo ""
fi

# Start services
echo "🐳 Starting services with Docker Compose..."
echo ""

docker-compose up --build -d

echo ""
echo "✅ Services are starting up!"
echo ""
echo "📍 Access points:"
echo "   - Web App:       http://localhost:3000"
echo "   - Agent Service: http://localhost:8000"
echo "   - MCP Server:    http://localhost:8080"
echo ""
echo "📊 View logs:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Stop services:"
echo "   docker-compose down"
echo ""
echo "Happy coding! 🎉"
