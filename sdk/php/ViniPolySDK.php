<?php
/**
 * ============================================================================
 * VINIPOLY DRM — OFFICIAL CLOUD API & CI/CD SDK FOR PHP (v1.1.3 - PHP 7.4/8.x)
 * ============================================================================
 * Bộ thư viện tích hợp chính thức cho nền tảng mã hóa bảo vệ mã nguồn PHP
 * thực thi trực tiếp trong RAM ViniPoly DRM (https://vinipoly.cm.io.vn).
 * ============================================================================
 */

namespace ViniPolyDRM;

use Exception;
use CURLFile;

class ViniPolyException extends Exception {
    public int $statusCode;
    public $details;

    public function __construct(string $message, int $statusCode = 0, $details = null) {
        parent::__construct($message, $statusCode);
        $this->statusCode = $statusCode;
        $this->details = $details;
    }
}

class ViniPolyClient {
    private string $apiKey;
    private string $baseUrl;
    private int $timeoutSec;
    private int $chunkSize;

    public function __construct(string $apiKey, array $options = []) {
        $apiKey = trim($apiKey);
        if ($apiKey === '') {
            throw new ViniPolyException('ViniPolyClient: API Key (VP_...) cannot be empty.', 400);
        }
        $this->apiKey = $apiKey;
        $this->baseUrl = rtrim(trim($options['base_url'] ?? 'https://vinipoly.cm.io.vn/api/drm'), '/');
        $this->timeoutSec = max(5, (int)($options['timeout'] ?? 60));
        $this->chunkSize = max(1024 * 1024, (int)($options['chunk_size'] ?? 10 * 1024 * 1024));
    }

    private function requestJson(string $method, string $path, ?array $jsonBody = null): array {
        $url = $this->baseUrl . '/' . ltrim($path, '/');
        $ch = curl_init($url);
        $headers = ['Accept: application/json'];

        if ($method === 'POST' && $jsonBody !== null) {
            $payload = json_encode($jsonBody);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
            $headers[] = 'Content-Type: application/json';
        }

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeoutSec);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

        $raw = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($raw === false) {
            throw new ViniPolyException('cURL network error: ' . $err, 0);
        }

        $decoded = json_decode((string)$raw, true);
        if ($status < 200 || $status >= 300) {
            throw new ViniPolyException(
                $decoded['error'] ?? ('HTTP Error ' . $status),
                $status,
                $decoded['details'] ?? $decoded
            );
        }
        return is_array($decoded) ? $decoded : ['raw' => $raw];
    }

    /** 1. Tra cứu thông tin gói cước, hạn ngạch (Quota) và Allowed Hosts (GET /api/drm/info) */
    public function getAccountInfo(): array {
        return $this->requestJson('GET', '/info?' . http_build_query(['api_key' => $this->apiKey]));
    }

    /** 2. Lấy cấu hình trạng thái khóa và tường lửa Allowed Hosts (GET /api/drm/settings) */
    public function getSecuritySettings(): array {
        return $this->requestJson('GET', '/settings?' . http_build_query(['api_key' => $this->apiKey]));
    }

    /** 3. Cập nhật trạng thái API Key ('active'|'inactive') và Allowed Hosts (POST /api/drm/settings) */
    public function updateSecuritySettings(string $status = 'active', string $allowedHosts = '*'): array {
        return $this->requestJson('POST', '/settings', [
            'api_key'       => $this->apiKey,
            'status'        => $status,
            'allowed_hosts' => $allowedHosts,
        ]);
    }

    /** 4. Lấy lịch sử 30 giao dịch mã hóa gần nhất (GET /api/drm/history) */
    public function getUsageHistory(): array {
        return $this->requestJson('GET', '/history?' . http_build_query(['api_key' => $this->apiKey]));
    }

    /** 5. Trừ hạn ngạch khi thực thi mã hóa cục bộ (POST /api/drm/deduct-quota) */
    public function deductQuota(int $fileCount): array {
        return $this->requestJson('POST', '/deduct-quota', [
            'api_key'    => $this->apiKey,
            'file_count' => $fileCount,
        ]);
    }

    /**
     * 6. Mã hóa toàn bộ gói ZIP dự án PHP sang .cme trên đám mây (Chunked Upload + Cloud Encode)
     * @param string $sourceZipPath Đường dẫn file .zip chứa mã nguồn .php
     * @param string $outputZipPath Đường dẫn lưu file Protected_by_ViniPoly.zip sau khi mã hóa
     */
    public function encodeProjectZip(string $sourceZipPath, string $outputZipPath): bool {
        if (!is_file($sourceZipPath)) {
            throw new ViniPolyException("Source ZIP file not found: {$sourceZipPath}", 400);
        }

        $uploadId = 'VP_' . strtoupper(bin2hex(random_bytes(4)));
        $fh = fopen($sourceZipPath, 'rb');
        if (!$fh) {
            throw new ViniPolyException("Cannot open source ZIP: {$sourceZipPath}", 400);
        }

        while (!feof($fh)) {
            $chunkData = fread($fh, $this->chunkSize);
            if ($chunkData === false || $chunkData === '') break;

            $tmpChunk = tempnam(sys_get_temp_dir(), 'vp_chunk_');
            file_put_contents($tmpChunk, $chunkData);

            $ch = curl_init($this->baseUrl . '/upload-chunk');
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeoutSec);
            curl_setopt($ch, CURLOPT_POSTFIELDS, [
                'upload_id' => $uploadId,
                'chunk'     => new CURLFile($tmpChunk, 'application/octet-stream', 'chunk.bin'),
            ]);
            $res = curl_exec($ch);
            $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            @unlink($tmpChunk);

            if ($code < 200 || $code >= 300) {
                fclose($fh);
                throw new ViniPolyException("Chunk upload failed with HTTP {$code}: {$res}", $code);
            }
        }
        fclose($fh);

        $ch = curl_init($this->baseUrl . '/cloud-encode');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeoutSec * 2);
        curl_setopt($ch, CURLOPT_POSTFIELDS, [
            'upload_id' => $uploadId,
            'api_key'   => $this->apiKey,
        ]);
        $rawZip = curl_exec($ch);
        $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($code < 200 || $code >= 300) {
            $err = json_decode((string)$rawZip, true);
            throw new ViniPolyException(
                $err['error'] ?? "Cloud encode failed (HTTP {$code})",
                $code,
                $err['details'] ?? null
            );
        }

        return file_put_contents($outputZipPath, $rawZip) !== false;
    }
}
