# 📊 Data Metadata MCP

**Model Context Protocol (MCP) server** written in Python to extract **metadata, statistics, and data samples** from files in **CSV, Excel, JSON, and Parquet** formats.

This MCP is ideal for enriching the context of language models or AI agents that need to analyze the structure and content of data before generating code or performing analysis.

---

## ✨ Features

- 📂 Supports formats: **CSV**, **Excel** (`.xls` / `.xlsx`), **JSON**, and **Parquet**.
- 📏 Returns **metadata**: number of rows, columns, data types, file size.
- 📊 Computes **basic statistics**: means, counts, and null values.
- 🗂 Extracts **schema and internal metadata** from Parquet files.
- 👀 Shows real data samples (first rows).
- ⚡ Compatible with any MCP client (Claude Desktop, VSCode MCP extension, etc.).

---

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/alcides-nolasco/mcp-data-metadata.git
   cd mcp-data-metadata
