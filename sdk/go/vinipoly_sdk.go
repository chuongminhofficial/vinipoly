// ============================================================================
// VINIPOLY DRM — OFFICIAL CLOUD API & CI/CD SDK FOR GO (v1.1.3 - Go 1.18+)
// ============================================================================
// Package vinipolysdk provides the official Go client for integrating with
// the ViniPoly DRM Cloud Gateway (https://vinipoly.cm.io.vn/api/drm).
// ============================================================================

package vinipolysdk

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

const DefaultBaseURL = "https://vinipoly.cm.io.vn/api/drm"

type APIError struct {
	StatusCode int    `json:"status_code"`
	Message    string `json:"error"`
	Details    string `json:"details,omitempty"`
}

func (e *APIError) Error() string {
	if e.Details != "" {
		return fmt.Sprintf("vinipoly error (HTTP %d): %s (%s)", e.StatusCode, e.Message, e.Details)
	}
	return fmt.Sprintf("vinipoly error (HTTP %d): %s", e.StatusCode, e.Message)
}

type Config struct {
	APIKey     string
	BaseURL    string
	Timeout    time.Duration
	ChunkSize  int
	HTTPClient *http.Client
}

type Client struct {
	apiKey     string
	baseURL    string
	chunkSize  int
	httpClient *http.Client
}

type AccountInfo struct {
	Plan   string `json:"plan"`
	Quota  int    `json:"quota"`
	Status string `json:"status"`
	Hosts  string `json:"hosts"`
	Expire string `json:"expire"`
}

type SecuritySettings struct {
	Status       string `json:"status"`
	AllowedHosts string `json:"allowed_hosts"`
}

type UsageHistoryItem struct {
	Action    string `json:"action"`
	FileCount int    `json:"file_count"`
	IP        string `json:"ip"`
	Time      string `json:"time"`
}

func NewClient(cfg Config) (*Client, error) {
	key := strings.TrimSpace(cfg.APIKey)
	if key == "" {
		return nil, fmt.Errorf("vinipolysdk: APIKey (VP_...) is required")
	}
	base := strings.TrimRight(strings.TrimSpace(cfg.BaseURL), "/")
	if base == "" {
		base = DefaultBaseURL
	}
	timeout := cfg.Timeout
	if timeout <= 0 {
		timeout = 60 * time.Second
	}
	chunkSize := cfg.ChunkSize
	if chunkSize <= 0 {
		chunkSize = 10 * 1024 * 1024
	}
	hc := cfg.HTTPClient
	if hc == nil {
		hc = &http.Client{Timeout: timeout}
	}
	return &Client{
		apiKey:     key,
		baseURL:    base,
		chunkSize:  chunkSize,
		httpClient: hc,
	}, nil
}

func (c *Client) doJSON(ctx context.Context, method, path string, payload interface{}, out interface{}) error {
	var bodyReader io.Reader
	if payload != nil {
		b, err := json.Marshal(payload)
		if err != nil {
			return err
		}
		bodyReader = bytes.NewReader(b)
	}

	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+"/"+strings.TrimLeft(path, "/"), bodyReader)
	if err != nil {
		return err
	}
	req.Header.Set("Accept", "application/json")
	if payload != nil {
		req.Header.Set("Content-Type", "application/json")
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		var apiErr APIError
		_ = json.Unmarshal(respBytes, &apiErr)
		apiErr.StatusCode = resp.StatusCode
		if apiErr.Message == "" {
			apiErr.Message = fmt.Sprintf("HTTP %d", resp.StatusCode)
		}
		return &apiErr
	}

	if out != nil {
		return json.Unmarshal(respBytes, out)
	}
	return nil
}

// GetAccountInfo fetches plan, quota, status, allowed_hosts, and expiration (GET /api/drm/info).
func (c *Client) GetAccountInfo(ctx context.Context) (*AccountInfo, error) {
	q := url.Values{}
	q.Set("api_key", c.apiKey)
	var res AccountInfo
	err := c.doJSON(ctx, http.MethodGet, "/info?"+q.Encode(), nil, &res)
	return &res, err
}

// GetSecuritySettings fetches API Key active status & Allowed Hosts (GET /api/drm/settings).
func (c *Client) GetSecuritySettings(ctx context.Context) (*SecuritySettings, error) {
	q := url.Values{}
	q.Set("api_key", c.apiKey)
	var res SecuritySettings
	err := c.doJSON(ctx, http.MethodGet, "/settings?"+q.Encode(), nil, &res)
	return &res, err
}

// UpdateSecuritySettings updates API Key status & Allowed Hosts (POST /api/drm/settings).
func (c *Client) UpdateSecuritySettings(ctx context.Context, status, allowedHosts string) error {
	payload := map[string]string{
		"api_key":       c.apiKey,
		"status":        status,
		"allowed_hosts": allowedHosts,
	}
	return c.doJSON(ctx, http.MethodPost, "/settings", payload, nil)
}

// GetUsageHistory fetches recent encoding transactions (GET /api/drm/history).
func (c *Client) GetUsageHistory(ctx context.Context) ([]UsageHistoryItem, error) {
	q := url.Values{}
	q.Set("api_key", c.apiKey)
	var res []UsageHistoryItem
	err := c.doJSON(ctx, http.MethodGet, "/history?"+q.Encode(), nil, &res)
	return res, err
}

// DeductQuota deducts file quota for local CLI builds (POST /api/drm/deduct-quota).
func (c *Client) DeductQuota(ctx context.Context, fileCount int) (int, error) {
	payload := map[string]interface{}{
		"api_key":    c.apiKey,
		"file_count": fileCount,
	}
	var res struct {
		Success   bool `json:"success"`
		Remaining int  `json:"remaining"`
	}
	err := c.doJSON(ctx, http.MethodPost, "/deduct-quota", payload, &res)
	return res.Remaining, err
}

// EncodeProjectZip uploads a ZIP archive in chunks and downloads the encrypted .cme archive.
func (c *Client) EncodeProjectZip(ctx context.Context, sourceZipPath, outputZipPath string) error {
	f, err := os.Open(sourceZipPath)
	if err != nil {
		return err
	}
	defer f.Close()

	randBytes := make([]byte, 4)
	_, _ = rand.Read(randBytes)
	uploadID := "VP_" + strings.ToUpper(hex.EncodeToString(randBytes))

	buf := make([]byte, c.chunkSize)
	for {
		n, readErr := f.Read(buf)
		if n > 0 {
			if err := c.uploadChunk(ctx, uploadID, buf[:n]); err != nil {
				return err
			}
		}
		if readErr == io.EOF {
			break
		}
		if readErr != nil {
			return readErr
		}
	}

	var body bytes.Buffer
	mw := multipart.NewWriter(&body)
	_ = mw.WriteField("upload_id", uploadID)
	_ = mw.WriteField("api_key", c.apiKey)
	_ = mw.Close()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/cloud-encode", &body)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", mw.FormDataContentType())

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		var apiErr APIError
		_ = json.Unmarshal(respBytes, &apiErr)
		apiErr.StatusCode = resp.StatusCode
		return &apiErr
	}
	return os.WriteFile(outputZipPath, respBytes, 0644)
}

func (c *Client) uploadChunk(ctx context.Context, uploadID string, chunk []byte) error {
	var body bytes.Buffer
	mw := multipart.NewWriter(&body)
	_ = mw.WriteField("upload_id", uploadID)
	fw, err := mw.CreateFormFile("chunk", "chunk.bin")
	if err != nil {
		return err
	}
	if _, err := fw.Write(chunk); err != nil {
		return err
	}
	_ = mw.Close()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/upload-chunk", &body)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", mw.FormDataContentType())

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		b, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("chunk upload failed (HTTP %d): %s", resp.StatusCode, string(b))
	}
	return nil
}
