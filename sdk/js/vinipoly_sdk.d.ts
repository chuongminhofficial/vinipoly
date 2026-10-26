/**
 * TypeScript Definitions for ViniPoly DRM Official Cloud SDK (v1.1.3)
 */

export interface ViniPolyClientConfig {
  /** ViniPoly API Key (e.g. 'VP_...') */
  apiKey: string;
  /** Cloud DRM Gateway URL (default: 'https://vinipoly.cm.io.vn/api/drm') */
  baseUrl?: string;
  /** Request timeout in milliseconds (default: 30000) */
  timeoutMs?: number;
  /** Chunk size in bytes for large ZIP uploads (default: 10485760 / 10MB) */
  chunkSize?: number;
}

export interface AccountInfoResponse {
  plan: 'trial' | 'free' | 'pro' | 'enterprise' | 'pay_to_go' | string;
  quota: number;
  status: 'active' | 'inactive' | string;
  hosts: string;
  expire: string;
}

export interface SecuritySettingsResponse {
  status: 'active' | 'inactive';
  allowed_hosts: string;
}

export interface UsageHistoryItem {
  action: string;
  file_count: number;
  ip: string;
  time: string;
}

export declare class ViniPolyError extends Error {
  statusCode: number;
  details: any;
  constructor(message: string, statusCode?: number, details?: any);
}

export declare class ViniPolyClient {
  apiKey: string;
  baseUrl: string;
  timeoutMs: number;
  chunkSize: number;

  constructor(config: ViniPolyClientConfig);
  getAccountInfo(): Promise<AccountInfoResponse>;
  getSecuritySettings(): Promise<SecuritySettingsResponse>;
  updateSecuritySettings(status?: 'active' | 'inactive', allowedHosts?: string | string[]): Promise<{ success: boolean }>;
  getUsageHistory(): Promise<UsageHistoryItem[]>;
  deductQuota(fileCount: number): Promise<{ success: boolean; remaining: number }>;
  uploadChunk(uploadId: string, chunkData: Blob | Buffer | Uint8Array): Promise<{ success: boolean }>;
  encodeProjectZip(zipInput: string | Buffer | Uint8Array, outputZipPath?: string | null): Promise<Buffer | Uint8Array>;
}
