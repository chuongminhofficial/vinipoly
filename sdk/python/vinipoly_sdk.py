#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
============================================================================
VINIPOLY DRM — OFFICIAL CLOUD API & CI/CD SDK FOR PYTHON (v1.1.3 - Python 3.8+)
============================================================================
Zero-dependency Python client library for automating PHP source code encryption
(.php -> .cme), quota inspection, and firewall management on ViniPoly DRM Cloud
(https://vinipoly.cm.io.vn).
============================================================================
"""

import json
import os
import uuid
import urllib.parse
import urllib.request
import urllib.error
from typing import Any, Dict, List, Optional


class ViniPolyError(Exception):
    """Structured exception raised by ViniPoly Cloud DRM API."""

    def __init__(self, message: str, status_code: int = 0, details: Any = None) -> None:
        super().__init__(f"[{status_code}] {message}")
        self.message = message
        self.status_code = status_code
        self.details = details


class ViniPolyClient:
    """Official Python SDK Client for ViniPoly DRM Cloud API."""

    def __init__(
        self,
        api_key: str,
        base_url: str = "https://vinipoly.cm.io.vn/api/drm",
        timeout: int = 60,
        chunk_size: int = 10 * 1024 * 1024,
    ) -> None:
        if not api_key or not str(api_key).strip():
            raise ValueError("ViniPolyClient: api_key (VP_...) is required.")
        self.api_key = str(api_key).strip()
        self.base_url = str(base_url).strip().rstrip("/")
        self.timeout = max(5, int(timeout))
        self.chunk_size = max(1024 * 1024, int(chunk_size))

    def _request_json(
        self,
        method: str,
        path: str,
        json_body: Optional[Dict[str, Any]] = None,
    ) -> Any:
        url = f"{self.base_url}/{path.lstrip('/')}"
        headers = {"Accept": "application/json", "User-Agent": "ViniPoly-Python-SDK/1.1.3"}
        data = None
        if json_body is not None:
            data = json.dumps(json_body).encode("utf-8")
            headers["Content-Type"] = "application/json"

        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                return json.loads(resp.read().decode("utf-8", errors="replace"))
        except urllib.error.HTTPError as e:
            raw = e.read().decode("utf-8", errors="replace")
            try:
                payload = json.loads(raw)
            except Exception:
                payload = {"error": raw}
            raise ViniPolyError(
                message=payload.get("error", f"HTTP Error {e.code}"),
                status_code=e.code,
                details=payload.get("details"),
            ) from e

    def get_account_info(self) -> Dict[str, Any]:
        """1. Fetch plan, remaining quota, expiration & Allowed Hosts (GET /api/drm/info)."""
        qs = urllib.parse.urlencode({"api_key": self.api_key})
        return self._request_json("GET", f"/info?{qs}")

    def get_security_settings(self) -> Dict[str, Any]:
        """2. Fetch API Key status & Allowed Hosts firewall (GET /api/drm/settings)."""
        qs = urllib.parse.urlencode({"api_key": self.api_key})
        return self._request_json("GET", f"/settings?{qs}")

    def update_security_settings(
        self, status: str = "active", allowed_hosts: str = "*"
    ) -> Dict[str, Any]:
        """3. Update API Key status ('active'|'inactive') & Allowed Hosts (POST /api/drm/settings)."""
        return self._request_json(
            "POST",
            "/settings",
            {
                "api_key": self.api_key,
                "status": status,
                "allowed_hosts": allowed_hosts,
            },
        )

    def get_usage_history(self) -> List[Dict[str, Any]]:
        """4. Fetch recent encoding usage logs (GET /api/drm/history)."""
        qs = urllib.parse.urlencode({"api_key": self.api_key})
        return self._request_json("GET", f"/history?{qs}")

    def deduct_quota(self, file_count: int) -> Dict[str, Any]:
        """5. Deduct quota for local CLI builds (POST /api/drm/deduct-quota)."""
        return self._request_json(
            "POST",
            "/deduct-quota",
            {"api_key": self.api_key, "file_count": int(file_count)},
        )

    def _post_multipart(
        self, path: str, fields: Dict[str, str], files: Optional[Dict[str, bytes]] = None
    ) -> bytes:
        boundary = f"----ViniPolyBoundary{uuid.uuid4().hex}"
        body = bytearray()

        for k, v in fields.items():
            body.extend(f"--{boundary}\r\n".encode("utf-8"))
            body.extend(f'Content-Disposition: form-data; name="{k}"\r\n\r\n'.encode("utf-8"))
            body.extend(f"{v}\r\n".encode("utf-8"))

        if files:
            for field_name, file_bytes in files.items():
                body.extend(f"--{boundary}\r\n".encode("utf-8"))
                body.extend(
                    f'Content-Disposition: form-data; name="{field_name}"; filename="chunk.bin"\r\n'.encode("utf-8")
                )
                body.extend(b"Content-Type: application/octet-stream\r\n\r\n")
                body.extend(file_bytes)
                body.extend(b"\r\n")

        body.extend(f"--{boundary}--\r\n".encode("utf-8"))
        url = f"{self.base_url}/{path.lstrip('/')}"
        req = urllib.request.Request(
            url,
            data=bytes(body),
            headers={
                "Content-Type": f"multipart/form-data; boundary={boundary}",
                "User-Agent": "ViniPoly-Python-SDK/1.1.3",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                return resp.read()
        except urllib.error.HTTPError as e:
            raw = e.read().decode("utf-8", errors="replace")
            try:
                payload = json.loads(raw)
            except Exception:
                payload = {"error": raw}
            raise ViniPolyError(
                message=payload.get("error", f"HTTP Error {e.code}"),
                status_code=e.code,
                details=payload.get("details"),
            ) from e

    def encode_project_zip(self, source_zip_path: str, output_zip_path: str) -> str:
        """
        6. Upload a project .zip in 10MB chunks and compile/encrypt .php -> .cme via Cloud API.
        Saves the protected ZIP archive to `output_zip_path`.
        """
        if not os.path.isfile(source_zip_path):
            raise FileNotFoundError(f"Source ZIP not found: {source_zip_path}")

        upload_id = "VP_" + uuid.uuid4().hex[:8].upper()
        with open(source_zip_path, "rb") as f:
            while True:
                chunk = f.read(self.chunk_size)
                if not chunk:
                    break
                self._post_multipart("/upload-chunk", {"upload_id": upload_id}, {"chunk": chunk})

        protected_bytes = self._post_multipart(
            "/cloud-encode", {"upload_id": upload_id, "api_key": self.api_key}
        )
        os.makedirs(os.path.dirname(os.path.abspath(output_zip_path)), exist_ok=True)
        with open(output_zip_path, "wb") as out_f:
            out_f.write(protected_bytes)
        return output_zip_path
