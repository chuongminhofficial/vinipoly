#!/usr/bin/env python3
"""
Quickstart Example — ViniPoly DRM Python SDK (v1.1.3)
Usage: VINIPOLY_API_KEY="VP_..." python3 examples/python_quickstart.py
"""
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../sdk/python")))
from vinipoly_sdk import ViniPolyClient, ViniPolyError


def main() -> None:
    api_key = os.getenv("VINIPOLY_API_KEY", "VP_your_api_key_here")
    client = ViniPolyClient(api_key=api_key)
    try:
        info = client.get_account_info()
        print("[Account Info]:", info)
    except ViniPolyError as e:
        print(f"ViniPoly Error [HTTP {e.status_code}]: {e.message}")


if __name__ == "__main__":
    main()
