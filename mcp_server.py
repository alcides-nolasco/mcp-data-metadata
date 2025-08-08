#!/usr/bin/env python3
import os
import json
import pandas as pd
import pyarrow.parquet as pq
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("Data Metadata MCP")

def get_file_size(path):
    return os.path.getsize(path)

def load_dataframe(file_path: str, limit: int = None) -> pd.DataFrame:
    """Loads a DataFrame from CSV, Excel, JSON or Parquet."""
    ext = os.path.splitext(file_path)[1].lower()
    if ext == ".csv":
        return pd.read_csv(file_path, nrows=limit)
    elif ext in [".xls", ".xlsx"]:
        return pd.read_excel(file_path, engine="openpyxl")
    elif ext == ".json":
        return pd.read_json(file_path)
    elif ext == ".parquet":
        return pd.read_parquet(file_path)
    else:
        raise ValueError("Formato no soportado")

@mcp.tool()
def get_metadata(file_path: str) -> dict:
    """Returns basic metadata of a file."""
    if not os.path.exists(file_path):
        return {"error": "File not found"}

    try:
        df = load_dataframe(file_path, limit=1000)
        return {
            "num_rows": len(df),
            "num_columns": len(df.columns),
            "columns": [{"name": col, "dtype": str(df[col].dtype)} for col in df.columns],
            "file_size_bytes": get_file_size(file_path)
        }
    except Exception as e:
        return {"error": str(e)}

@mcp.tool()
def get_statistics(file_path: str) -> dict:
    """Returns basic statistics of a file."""
    if not os.path.exists(file_path):
        return {"error": "File not found"}

    try:
        df = load_dataframe(file_path)
        return {
            "mean": df.mean(numeric_only=True).to_dict(),
            "count": df.count().to_dict(),
            "nulls": df.isnull().sum().to_dict()
        }
    except Exception as e:
        return {"error": str(e)}

@mcp.tool()
def get_parquet_schema(file_path: str) -> dict:
    """Returns schema and internal metadata of a Parquet file."""
    if not os.path.exists(file_path):
        return {"error": "File not found"}
    if not file_path.lower().endswith(".parquet"):
        return {"error": "File is not Parquet"}

    try:
        parquet_file = pq.ParquetFile(file_path)
        return {
            "schema": str(parquet_file.schema),
            "metadata": parquet_file.metadata.to_dict()
        }
    except Exception as e:
        return {"error": str(e)}

@mcp.tool()
def get_sample_rows(file_path: str, num_rows: int = 5) -> dict:
    """
    Returns a sample of the first rows of the file.
    - num_rows: number of rows to show (default 5)
    """
    if not os.path.exists(file_path):
        return {"error": "File not found"}

    try:
        df = load_dataframe(file_path, limit=num_rows)
        # Convert to a format that can be sent as JSON
        return {
            "sample": df.head(num_rows).to_dict(orient="records")
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    mcp.run()
