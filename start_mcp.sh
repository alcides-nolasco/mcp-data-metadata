#!/bin/bash

# ===============================
#  MCP Server Setup Script
# ===============================

# Variables
PROJECT_NAME="mcp-data-metadata"
VENV_DIR=".venv"
MCP_JSON_NAME="mcp_servers.json"

# Detect OS and set VSCode user settings path
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VSCODE_USER_DIR="$HOME/.config/Code/User"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    VSCODE_USER_DIR="$APPDATA/Code/User"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

# Step 1: Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv "$VENV_DIR"

# Step 2: Activate venv and install dependencies
echo "📥 Installing dependencies..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install pandas pyarrow openpyxl numpy fastapi mcp[fastmcp]

 
# Step 3: Add MCP server config to VSCode
echo "⚙️ Adding MCP server configuration to VSCode..."
mkdir -p "$VSCODE_USER_DIR"

MCP_CONFIG_FILE="$VSCODE_USER_DIR/$MCP_JSON_NAME"

if [[ ! -f "$MCP_CONFIG_FILE" ]]; then
    echo "{}" > "$MCP_CONFIG_FILE"
fi

python3 <<EOF
import json
import os

file_path = "$MCP_CONFIG_FILE"
project_path = os.path.abspath("mcp_server.py")

with open(file_path, "r", encoding="utf-8") as f:
    try:
        config = json.load(f)
    except json.JSONDecodeError:
        config = {}

config["data-metadata-mcp"] = {
    "command": "python",
    "args": [project_path],
    "env": {},
    "capabilities": {
        "tools": True,
        "resources": False,
        "prompts": False
    }
}

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(config, f, indent=4)

print("✅ MCP server configuration updated in", file_path)
EOF

# Step 4: Add project to PATH
ABS_PATH=$(pwd)
if [[ ":$PATH:" != *":$ABS_PATH:"* ]]; then
    echo "export PATH=\"\$PATH:$ABS_PATH\"" >> ~/.bashrc
    echo "export PATH=\"\$PATH:$ABS_PATH\"" >> ~/.zshrc
    echo "✅ Added project directory to PATH."
fi

# Step 5: Start MCP server
echo "🚀 Starting MCP server..."
python3 /Users/cnolasco/myworkspace/mcp-data-metadata/mcp_server.py
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to start MCP server."
    exit 1
fi