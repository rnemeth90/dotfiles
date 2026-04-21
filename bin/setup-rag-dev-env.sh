#!/bin/bash

echo "============================================"
echo "🚀 Setting up RAG Development Environment"
echo "============================================"

# Navigate to the rag-debugging directory
mkdir ./rag-debugging
cd ./rag-debugging

# Create Python virtual environment
echo "📦 Creating Python virtual environment..."
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install UV package manager
echo "⚡ Installing UV package manager..."
pip install uv

# Install required packages
echo "📚 Installing RAG dependencies..."
uv pip install chromadb sentence-transformers openai tiktoken rank-bm25

# Create setup complete marker
echo "SETUP_COMPLETE" > ./setup-complete.txt

echo ""
echo "============================================"
echo "✅ RAG Environment Setup Complete!"
echo "============================================"
echo ""
