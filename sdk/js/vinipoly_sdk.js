/**
 * ============================================================================
 * VINIPOLY DRM — OFFICIAL CLOUD API & CI/CD SDK FOR JAVASCRIPT / NODE.JS (v1.1.3)
 * ============================================================================
 * Official client library for integrating ViniPoly Enterprise PHP Source Code
 * Protection & Zero-Disk RAM Execution Platform (https://vinipoly.cm.io.vn).
 *
 * Features / Tính năng:
 * - Check account plan, remaining file quota & Allowed Hosts (/api/drm/info)
 * - Manage API Key status & Allowed Hosts IP/Domain Firewall (/api/drm/settings)
 * - Fetch encoding audit logs & transaction history (/api/drm/history)
 * - Deduct quota for custom local CLI builds (/api/drm/deduct-quota)
 * - Automated 10MB chunked ZIP upload & Cloud Encryption (/upload-chunk + /cloud-encode)
 * ============================================================================
 */

const fs = typeof require !== 'undefined' ? require('fs') : null;
const path = typeof require !== 'undefined' ? require('path') : null;

class ViniPolyError extends Error {
  constructor(message, statusCode = 0, details = null) {
    super(message);
    this.name = 'ViniPolyError';
    this.statusCode = statusCode;
    this.details = details;
  }
}

class ViniPolyClient {
  /**
   * Initialize ViniPoly DRM Cloud Client
   * @param {Object} config
   * @param {string} config.apiKey - ViniPoly API Key (e.g. 'VP_...')
   * @param {string} [config.baseUrl='https://vinipoly.cm.io.vn/api/drm'] - Cloud DRM Gateway URL
   * @param {number} [config.timeoutMs=30000] - Request timeout in ms
   * @param {number} [config.chunkSize=10485760] - Chunk size in bytes (default 10MB)
   */
  constructor(config = {}) {
    if (!config || !config.apiKey || typeof config.apiKey !== 'string') {
      throw new Error('ViniPolyClient: Missing required "apiKey" (VP_...).');
    }
    this.apiKey = config.apiKey.trim();
    this.baseUrl = (config.baseUrl || 'https://vinipoly.cm.io.vn/api/drm').trim().replace(/\/+$/, '');
    this.timeoutMs = Number(config.timeoutMs) > 0 ? Number(config.timeoutMs) : 30000;
    this.chunkSize = Number(config.chunkSize) > 0 ? Number(config.chunkSize) : 10 * 1024 * 1024;
  }

  async _requestJson(endpoint, options = {}) {
    const url = `${this.baseUrl}/${endpoint.replace(/^\/+/, '')}`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const res = await fetch(url, {
        ...options,
        signal: controller.signal,
      });
      clearTimeout(timer);
      const text = await res.text();
      let data = null;
      try {
        data = JSON.parse(text);
      } catch (_) {
        data = { raw: text };
      }
      if (!res.ok) {
        throw new ViniPolyError(
          data?.error || `HTTP Error ${res.status}`,
          res.status,
          data?.details || data
        );
      }
      return data;
    } catch (err) {
      clearTimeout(timer);
      throw err;
    }
  }

  /**
   * 1. Get Account Plan, Remaining File Quota, Expiration & Firewall Hosts (GET /api/drm/info)
   */
  async getAccountInfo() {
    const qs = new URLSearchParams({ api_key: this.apiKey }).toString();
    return this._requestJson(`/info?${qs}`, { method: 'GET' });
  }

  /**
   * 2. Get API Key Status & Allowed Hosts Firewall Configuration (GET /api/drm/settings)
   */
  async getSecuritySettings() {
    const qs = new URLSearchParams({ api_key: this.apiKey }).toString();
    return this._requestJson(`/settings?${qs}`, { method: 'GET' });
  }

  /**
   * 3. Update API Key Status ('active'|'inactive') & Allowed Hosts Firewall (POST /api/drm/settings)
   * @param {'active'|'inactive'} status
   * @param {string|string[]} allowedHosts - e.g. '*' or '103.69.96.31, domain.com'
   */
  async updateSecuritySettings(status = 'active', allowedHosts = '*') {
    const hostsStr = Array.isArray(allowedHosts) ? allowedHosts.join(', ') : String(allowedHosts || '*');
    return this._requestJson('/settings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        api_key: this.apiKey,
        status,
        allowed_hosts: hostsStr,
      }),
    });
  }

  /**
   * 4. Get Recent Encoding Transaction History (GET /api/drm/history)
   */
  async getUsageHistory() {
    const qs = new URLSearchParams({ api_key: this.apiKey }).toString();
    return this._requestJson(`/history?${qs}`, { method: 'GET' });
  }

  /**
   * 5. Deduct Quota for Local CLI Encoding (POST /api/drm/deduct-quota)
   * @param {number} fileCount
   */
  async deductQuota(fileCount) {
    return this._requestJson('/deduct-quota', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        api_key: this.apiKey,
        file_count: Number(fileCount),
      }),
    });
  }

  /**
   * 6. Upload a Single Binary Chunk (POST /api/drm/upload-chunk)
   * @param {string} uploadId
   * @param {Blob|Buffer|Uint8Array} chunkData
   */
  async uploadChunk(uploadId, chunkData) {
    const form = new FormData();
    form.append('upload_id', uploadId);
    const blob = chunkData instanceof Blob ? chunkData : new Blob([chunkData]);
    form.append('chunk', blob, 'chunk.bin');

    return this._requestJson('/upload-chunk', {
      method: 'POST',
      body: form,
    });
  }

  /**
   * 7. Trigger Cloud Rust Core Encryption & Download Protected Archive (POST /api/drm/cloud-encode)
   * Automatically splits input ZIP into 10MB chunks, uploads them, compiles .php -> .cme,
   * and returns the encrypted ZIP Buffer (or saves directly to outputZipPath in Node.js).
   *
   * @param {string|Buffer|Uint8Array} zipInput - Path to local .zip file or Buffer
   * @param {string} [outputZipPath] - Optional destination file path to save Protected_by_ViniPoly.zip
   * @returns {Promise<Buffer|Uint8Array>}
   */
  async encodeProjectZip(zipInput, outputZipPath = null) {
    let buffer;
    if (typeof zipInput === 'string') {
      if (!fs) throw new Error('File system access requires Node.js runtime.');
      buffer = fs.readFileSync(zipInput);
    } else {
      buffer = zipInput;
    }

    const uploadId = 'VP_' + Math.random().toString(36).substring(2, 10).toUpperCase();
    const totalChunks = Math.ceil(buffer.length / this.chunkSize);

    for (let i = 0; i < totalChunks; i++) {
      const slice = buffer.subarray(i * this.chunkSize, Math.min((i + 1) * this.chunkSize, buffer.length));
      await this.uploadChunk(uploadId, slice);
    }

    const form = new FormData();
    form.append('upload_id', uploadId);
    form.append('api_key', this.apiKey);

    const res = await fetch(`${this.baseUrl}/cloud-encode`, {
      method: 'POST',
      body: form,
    });

    if (!res.ok) {
      let errPayload = null;
      try {
        errPayload = await res.json();
      } catch (_) {}
      throw new ViniPolyError(
        errPayload?.error || `Cloud Encode failed with HTTP ${res.status}`,
        res.status,
        errPayload?.details || errPayload
      );
    }

    const arrayBuf = await res.arrayBuffer();
    const outBuffer = typeof Buffer !== 'undefined' ? Buffer.from(arrayBuf) : new Uint8Array(arrayBuf);

    if (outputZipPath && fs) {
      fs.mkdirSync(path.dirname(path.resolve(outputZipPath)), { recursive: true });
      fs.writeFileSync(outputZipPath, outBuffer);
    }
    return outBuffer;
  }
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { ViniPolyClient, ViniPolyError };
}
