<div align="center">

# 🛡️ ViniPoly DRM — Enterprise PHP Source Code Encryption & Zero-Disk RAM Execution Platform

**Military-Grade AES-256-GCM Source Protection (`.php` $\rightarrow$ `.cme`), Native Zend Extension RAM Execution & Cloud CI/CD SDK Suite**

[![CLI Version](https://img.shields.io/badge/CLI%20Console-v1.1.3-0A66C2?style=flat-square)](#2-one-line-linux-server-installation-vinipoly-cli)
[![Core Engine](https://img.shields.io/badge/Core%20Engine-v2.5.0%20Production-10B981?style=flat-square)](#)
[![PHP Support](https://img.shields.io/badge/PHP-7.3%20--%208.3%20(Zend%20.so)-6366F1?style=flat-square)](#1-core-security-architecture)
[![Web Servers](https://img.shields.io/badge/Web%20Servers-Nginx%20%7C%20Apache%20%7C%20OpenLiteSpeed-F59E0B?style=flat-square)](#3-web-server--clean-url-routing-cme)
[![License: MIT](https://img.shields.io/badge/SDK%20License-MIT-22C55E?style=flat-square)](LICENSE)

**[🇬🇧 English Documentation](README.md)** · **[🇻🇳 Tài Liệu Tiếng Việt](README.vi.md)** · **[📘 Full Integration Guide (EN)](docs/en/INTEGRATION_GUIDE.md)** · **[📗 Tài Liệu Tích Hợp (VI)](docs/vi/INTEGRATION_GUIDE.md)** · **[🚀 Postman Collections](postman/)**

</div>

## Overview

Welcome to the official public developer repository for **ViniPoly DRM** (developed by **Chương Minh® Studio**). ViniPoly DRM is an enterprise-grade PHP source code protection and digital rights management ecosystem designed to eliminate unauthorized source code theft, reverse engineering, and license tampering when distributing commercial PHP applications, SaaS platforms, WordPress themes/plugins, and Laravel/Symfony systems.

Unlike legacy obfuscators that merely scramble variable names or write temporary decrypted files to `/tmp`, **ViniPoly DRM** compiles and encrypts `.php` source files into binary **`.cme` (Chương Minh Encrypted)** payloads using **AES-256-GCM** and executes them **100% directly in RAM** via the native C/Rust Zend Extension (`vinipoly.so`).

> **Security & Architecture Note**: This public repository contains the **Official Cloud DRM SDKs (JS/TS, PHP, Python, Go), Sanitized Server CLI Console, Web Server Configuration Templates, RAM Execution Test Suite, and Postman Collections**. The underlying Rust Core Encoder (`vinipoly-encoder`), Zend Extension (`vinipoly.so`), and Cloud DRM Gateway (`https://vinipoly.cm.io.vn`) are proprietary commercial software.

## 1. Core Security Architecture

* **Zero-Disk In-Memory Execution (`vinipoly.so`)**: Decryption and Zend opcode execution occur entirely inside volatile memory (RAM). Zero plaintext PHP code is ever written to the hard drive or swap space.
* **Military-Grade Cryptographic Envelope (`AES-256-GCM` + Dual-Key Binding)**:
  * **Cloud API Key (`VP_...`)**: Authenticates your encoding requests against the ViniPoly Cloud DRM Gateway (`https://vinipoly.cm.io.vn/api/drm`) and enforces IP/Domain firewall rules (`Allowed Hosts`).
  * **Local Recovery License Key (`REC_...`)**: Stored locally at `/www/server/vinipoly.license` (`chmod 644`) on your target server to authorize real-time in-memory runtime execution.
* **Frontend Cloaking & 100% SEO Compatibility**: Protects rendered output while remaining completely transparent and friendly to search engine crawlers (Googlebot, Bingbot).
* **Universal PHP & Web Server Compatibility**:
  * **PHP Versions**: `7.3`, `7.4`, `8.0`, `8.1`, `8.2`, `8.3` (`php-fpm`, `php-cli`, and `lsphp`).
  * **Web Servers & Panels**: Native auto-routing for **Nginx**, **Apache**, **OpenLiteSpeed**, and **aaPanel**.

## 2. Repository Structure

```text
vinipoly-drm/
├── cli/
│   └── install-public.sh                        # Official Linux CLI Installer & Local Smart Encoder Console (v1.1.3)
├── configs/
│   ├── apache/.htaccess                         # Clean URL & .cme extensionless routing for Apache/OpenLiteSpeed
│   ├── nginx/vinipoly-cme.conf                  # Nginx FastCGI configuration for .php & .cme execution
│   └── php/.user.ini.example                    # Recommended open_basedir configuration
├── docs/
│   ├── en/INTEGRATION_GUIDE.md                  # Comprehensive English Integration & Cloud API Guide
│   └── vi/INTEGRATION_GUIDE.md                  # Tài liệu tích hợp & Hướng dẫn sử dụng toàn diện (Tiếng Việt)
├── examples/
│   ├── php-ram-test/                            # Official PHP RAM Execution Test Suite (source_test.php & testcore.php)
│   ├── js_quickstart.js                         # Node.js / TypeScript Cloud DRM SDK Quickstart
│   ├── php_quickstart.php                       # PHP Cloud DRM SDK Quickstart
│   ├── python_quickstart.py                     # Python Cloud DRM SDK Quickstart
│   └── go_quickstart.go                         # Go Cloud DRM SDK Quickstart
├── postman/
│   ├── vinipoly_drm_postman_collection.en.json  # Postman Collection v2.1.0 (English)
│   └── vinipoly_drm_postman_collection.vi.json  # Postman Collection v2.1.0 (Tiếng Việt)
├── sdk/
│   ├── js/                                      # JavaScript / TypeScript SDK (vinipoly_sdk.js + .d.ts)
│   ├── php/                                     # PHP 7.4/8.x SDK (ViniPolySDK.php + composer.json)
│   ├── python/                                  # Python 3.8+ Zero-Dependency SDK (vinipoly_sdk.py)
│   └── go/                                      # Go 1.18+ SDK (vinipoly_sdk.go + go.mod)
├── README.md                                    # English README (Default)
├── README.vi.md                                 # Vietnamese README (Tiếng Việt)
├── SECURITY.md                                  # Bilingual Security Policy
├── CONTRIBUTING.md                              # Bilingual Contribution Guide
├── CHANGELOG.md                                 # Release History
└── LICENSE                                      # MIT License (Public Client Suite)
```

## 3. One-Line Linux Server Installation (`vinipoly` CLI)

Run the following single command as `root` on your Linux VPS/Server (Ubuntu, Debian, CentOS, AlmaLinux, Rocky Linux with aaPanel) to install the ViniPoly CLI Console, auto-detect all installed PHP versions (`7.3`–`8.3`), attach the `vinipoly.so` Zend Extension, and configure your web server:

```bash
curl -s -O https://cdn.chgm.in/install/v1.1.3/installer_vinipoly && chmod +x installer_vinipoly && ./installer_vinipoly
```

Once installed, simply type `vinipoly` in your terminal at any time to launch the interactive management dashboard:

| Menu Key | Feature Name | Description |
| :---: | :--- | :--- |
| **`[1]`** | **Install PHP Core** | Scans `/www/server/php/*` (PHP 7.3–8.3), installs `vinipoly.so`, and reloads `php-fpm` / `lsphp`. |
| **`[2]`** | **Key Management** | Update your Local Recovery License Key (`/www/server/vinipoly.license`) or Cloud API Key (`/www/server/vinipoly.apikey`). |
| **`[3]`** | **Smart Local Encoder** | Scans a project directory or single `.php` file (automatically skipping `vendor/` & `node_modules/`), checks Cloud Quota, compiles `.php` $\rightarrow$ `.cme` locally via `vinipoly-encoder`, and optionally removes original `.php` files. |
| **`[4]`** | **Service Health Check** | Verifies running status of Nginx/Apache/OpenLiteSpeed, `vinipoly.so` per PHP version, and license permissions (`644`). |
| **`[5]`** | **Cloud Account Info** | Queries `/api/drm/info` to display active Subscription Plan, Remaining File Quota, Allowed Hosts Firewall, and Expiration Date. |
| **`[6]`** | **Auto-Update** | Checks `https://cdn.chgm.in/install/version.txt` and upgrades the CLI binary in-place. |
| **`[7]`** | **Web Server Reroute** | Automatically configures Nginx, Apache, and OpenLiteSpeed to execute `.cme` files natively. |

## 4. Official Cloud DRM SDKs & CI/CD Automation

Integrate ViniPoly Cloud Encryption directly into your build pipelines or deployment scripts using our 4 official SDKs:

### 4.1. JavaScript / TypeScript (`sdk/js/vinipoly_sdk.js`)
```javascript
const { ViniPolyClient } = require('./sdk/js/vinipoly_sdk.js');

const client = new ViniPolyClient({
  apiKey: process.env.VINIPOLY_API_KEY || 'VP_your_api_key_here',
});

// 1. Check account plan, remaining file quota & Allowed Hosts
const info = await client.getAccountInfo();
console.log(`Plan: ${info.plan.toUpperCase()} | Remaining Quota: ${info.quota} files`);

// 2. Automatically upload source.zip in 10MB chunks & download encrypted .cme archive
await client.encodeProjectZip('./dist/my-project-src.zip', './dist/Protected_by_ViniPoly.zip');
```

### 4.2. PHP (`sdk/php/ViniPolySDK.php`)
```php
<?php
require_once __DIR__ . '/sdk/php/ViniPolySDK.php';

use ViniPolyDRM\ViniPolyClient;

$client = new ViniPolyClient(getenv('VINIPOLY_API_KEY') ?: 'VP_your_api_key_here');

$info = $client->getAccountInfo();
echo "Remaining Quota: {$info['quota']} files\n";

// Encrypt a ZIP archive in the cloud and save Protected_by_ViniPoly.zip
$client->encodeProjectZip(__DIR__ . '/source.zip', __DIR__ . '/Protected_by_ViniPoly.zip');
```

### 4.3. Python (`sdk/python/vinipoly_sdk.py`)
```python
from sdk.python.vinipoly_sdk import ViniPolyClient

client = ViniPolyClient(api_key="VP_your_api_key_here")

info = client.get_account_info()
print(f"Plan: {info['plan']} | Quota: {info['quota']} files")

# Chunked upload & cloud encryption (.php -> .cme)
client.encode_project_zip("source.zip", "Protected_by_ViniPoly.zip")
```

### 4.4. Go (`sdk/go/vinipoly_sdk.go`)
```go
package main

import (
	"context"
	"fmt"
	vinipolysdk "github.com/vinipoly-drm/vinipoly-sdk/sdk/go"
)

func main() {
	client, _ := vinipolysdk.NewClient(vinipolysdk.Config{
		APIKey: "VP_your_api_key_here",
	})
	ctx := context.Background()

	info, _ := client.GetAccountInfo(ctx)
	fmt.Printf("Plan: %s | Quota: %d files\n", info.Plan, info.Quota)

	_ = client.EncodeProjectZip(ctx, "source.zip", "Protected_by_ViniPoly.zip")
}
```

## 5. Cloud DRM REST API Reference (`https://vinipoly.cm.io.vn/api/drm`)

| # | Method & Path | Authentication | Request Payload / Params | Description |
| :---: | :--- | :--- | :--- | :--- |
| 01 | `GET /api/drm/info` | `?api_key=VP_...` | Query `api_key` | Returns subscription `plan`, remaining `quota`, `status`, `hosts`, and `expire` date. |
| 02 | `GET /api/drm/settings` | `?api_key=VP_...` | Query `api_key` | Returns current API Key `status` (`active`/`inactive`) and `allowed_hosts` firewall list. |
| 03 | `POST /api/drm/settings` | JSON `api_key` | `{"api_key", "status", "allowed_hosts"}` | Updates API Key status toggle and IP/Domain whitelist (`*` or comma-separated hosts). |
| 04 | `GET /api/drm/history` | `?api_key=VP_...` | Query `api_key` | Returns the latest 30 encoding transactions (`action`, `file_count`, `ip`, `time`). |
| 05 | `POST /api/drm/deduct-quota` | JSON `api_key` | `{"api_key", "file_count"}` | Verifies and deducts file quota for authenticated Local CLI Encoder executions. |
| 06 | `POST /api/drm/upload-chunk` | Multipart Form | `upload_id`, `chunk` (10MB binary) | Appends a binary ZIP chunk to a temporary cloud build workspace. |
| 07 | `POST /api/drm/cloud-encode` | Multipart Form | `upload_id`, `api_key` | Verifies `Allowed Hosts` & quota, compiles `.php` $\rightarrow$ `.cme`, and returns `Protected_by_ViniPoly.zip`. |

## 6. Subscription Plans & Quota Tiers

| Plan Tier | Code (`plan_type`) | File Quota | Validity Cycle | Best For |
| :--- | :--- | :--- | :--- | :--- |
| **Trial** | `trial` | `3 files` | 30 Days | Initial testing with `examples/php-ram-test/` |
| **Free** | `free` | `30 files` | 30 Days | Small personal scripts & single modules |
| **Pro** | `pro` | `150 files` | 30 Days | Commercial plugins, themes & medium web apps |
| **Enterprise** | `enterprise` | `520 files` | 30 Days | Full-scale SaaS platforms & enterprise ERP/CRM |
| **Pay-As-You-Go** | `pay_to_go` | Custom Top-Up | **Lifetime (Never Expires)** | On-demand production releases & CI/CD pipelines |

## License

The client SDKs, server configuration templates, and integration examples in this repository are licensed under the [MIT License](LICENSE).
