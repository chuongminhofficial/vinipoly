<div align="center">

# 🛡️ ViniPoly DRM v3.0
### Enterprise PHP Source Protection, Zero-Disk RAM Execution & Real-Time Payload Vault

[![Release](https://img.shields.io/badge/Release-v3.0.0-0EA5E9?style=flat-square)](release.manifest.json)
[![PHP Support](https://img.shields.io/badge/PHP-7.3%20–%208.5%20(Native%20.so)-6366F1?style=flat-square)](#2-direct-raw-binary-downloads-linux-x86_64)
[![Web Servers](https://img.shields.io/badge/Web%20Servers-Nginx%20%7C%20Apache%20%7C%20OpenLiteSpeed-10B981?style=flat-square)](#4-web-server--clean-url-routing)
[![Platform](https://img.shields.io/badge/Platform-Linux%20x86__64-0F172A?style=flat-square)](#1-one-line-quick-install-linux-x86_64)
[![Vendor](https://img.shields.io/badge/By-Chương%20Minh%20Studio-38BDF8?style=flat-square)](https://chuongminh.com/vinipoly)

**[🇻🇳 Tài Liệu Tiếng Việt](README.vi.md)** · **[🇬🇧 English Documentation](README.md)** · **[📦 SHA-256 Checksums](SHA256SUMS.txt)** · **[📜 Release Manifest](release.manifest.json)** · **[📘 Integration Guide](docs/en/INTEGRATION_GUIDE.md)**

</div>

---

## Overview

**ViniPoly DRM v3.0** (by **Chương Minh® Studio**) is a commercial-grade PHP intellectual property protection, source code encryption (`.php` → `.cme`), and runtime payload security platform built for SaaS vendors, enterprise portals, payment/SSO gateways, Laravel/Symfony applications, and WordPress ecosystems.

Unlike traditional obfuscators that scramble text or write temporary files to disk, **ViniPoly v3.0** compiles PHP projects into authenticated **`CM_ENC v3` (`.cme`)** containers with per-file cryptographic keys and executes them **100% directly in Zend Engine RAM** via the native C extension (`vinipoly.so`) — with **zero `eval()`**, **zero disk residue**, and **100% native PHP compatibility**.

---

## 1. One-Line Quick Install (Linux x86_64)

Install the compiled **ViniPoly v3.0 Smart Console** (`/usr/local/bin/vinipoly`), auto-detect all installed PHP versions (`7.3` through `8.5`), and configure Nginx / Apache / OpenLiteSpeed automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/installer_vinipoly -o /usr/local/bin/vinipoly && chmod +x /usr/local/bin/vinipoly && vinipoly
```

### Install Standalone CLI Encoder & Decoder Directly via Raw URLs

```bash
# Install Native Rust Encoder & Owner Recovery Decoder
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-encoder -o /usr/local/bin/vinipoly-encoder && chmod +x /usr/local/bin/vinipoly-encoder
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-decoder -o /usr/local/bin/vinipoly-decoder && chmod +x /usr/local/bin/vinipoly-decoder
```

### Manual Single-Command `.so` Deployment (Example: PHP 8.3)

```bash
EXT_DIR=$(php-config --extension-dir)
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php83/vinipoly.so -o "${EXT_DIR}/vinipoly.so"
chmod 755 "${EXT_DIR}/vinipoly.so"
```

---

## 2. Direct Raw Binary Downloads (Linux x86_64)

All official distribution binaries in this repository are committed as **native raw Git blobs (no Git LFS throttling)** so automated CI/CD pipelines, Dockerfiles, and production servers can download them directly via `curl` or `wget`.

| Component | Target | Size | SHA-256 (Prefix) | Direct Raw Download |
| :--- | :--- | :---: | :---: | :--- |
| **`installer_vinipoly`** | Smart Server Installer & CLI Console | 48.2 KB | `3ecd7625f12f887f…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/installer_vinipoly) |
| **`bin/vinipoly-encoder`** | Native Rust VPC3 AST Encoder CLI | 8.34 MB | `ec520eba7cc32617…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-encoder) |
| **`bin/vinipoly-decoder`** | Owner & License Vault Recovery CLI | 8.40 MB | `b8ca185264e809f3…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-decoder) |
| **`release-so/php73/vinipoly.so`** | Zend Native Loader — **PHP 7.3** | 413.5 KB | `69d7e0b20adc2b93…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php73/vinipoly.so) |
| **`release-so/php74/vinipoly.so`** | Zend Native Loader — **PHP 7.4** | 412.7 KB | `cfe0e8178c0a845f…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php74/vinipoly.so) |
| **`release-so/php80/vinipoly.so`** | Zend Native Loader — **PHP 8.0** | 411.9 KB | `aa84c298bff392ff…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php80/vinipoly.so) |
| **`release-so/php81/vinipoly.so`** | Zend Native Loader — **PHP 8.1** | 414.1 KB | `cbff8be3467cf548…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php81/vinipoly.so) |
| **`release-so/php82/vinipoly.so`** | Zend Native Loader — **PHP 8.2** | 417.6 KB | `35ebb6d7d4227918…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php82/vinipoly.so) |
| **`release-so/php83/vinipoly.so`** | Zend Native Loader — **PHP 8.3** | 418.0 KB | `3aa93bb17d4da660…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php83/vinipoly.so) |
| **`release-so/php84/vinipoly.so`** | Zend Native Loader — **PHP 8.4** | 421.9 KB | `d88746198942c8ae…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php84/vinipoly.so) |
| **`release-so/php85/vinipoly.so`** | Zend Native Loader — **PHP 8.5** | 422.8 KB | `582e5c811c15f951…` | [Download Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php85/vinipoly.so) |

> **Integrity Verification**: Verify any downloaded binary against [SHA256SUMS.txt](SHA256SUMS.txt):
> ```bash
> curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/SHA256SUMS.txt | sha256sum -c --ignore-missing
> ```

---

## 3. What's New in ViniPoly v3.0

- **100% Native Zero-Eval Zend Execution (`vinipoly.so`)**: Compiles decrypted opcodes directly into Zend Engine RAM across **PHP 7.3 – 8.5** without `eval()` or temporary files.
- **Transparent PHP Ecosystem Hooks**: Built-in Zend path & stat hooks seamlessly resolve `require`, `include`, PSR-4 Composer autoloaders, `file_exists()`, `is_file()`, and `is_readable()` from `.php` to `.cme` without modifying application code.
- **Token-Safe AST Secret Vault (`vinipoly-encoder`)**: Automatically seals sensitive credentials, database DSNs, JWT keys, and payment/webhook secrets inside per-file hardware-attested vaults while preserving Heredocs/Nowdocs, PHP 8 Attributes, Enums, `declare(strict_types=1)`, and static frontend assets (`.js`, `.css`, `.png`, `.json`, `.htaccess`).
- **Real-Time 2-Way Payload & Polymorphic DOM Vault**: Transparently encrypts HTML delivery and `fetch` / `XMLHttpRequest` API payloads while keeping external SDKs, OAuth2 callbacks, webhooks, and Cloudflare Turnstile 100% interference-free.
- **Frameless Responsive Multilingual + RTL F12 Shield**: Closed Shadow DOM DevTools protection featuring the Midnight Horizon canvas, 11 built-in languages, and native Right-to-Left (`RTL`) layout for Arabic, Persian, and Hebrew, while preserving live session inputs with zero page reload.
- **Native FCrDNS Search Bot Gatekeeper**: Cryptographic reverse/forward DNS verification ensures verified crawlers (Googlebot, Bingbot, Applebot) index SEO metadata cleanly while blocking User-Agent spoofing.
- **Lossless Owner & Emergency Recovery (`vinipoly-decoder`)**: Authorized license holders can restore `.cme` packages back to bit-exact original `.php` source files anytime, even after rotating API keys.

---

## 4. Web Server & Clean URL Routing

Running `vinipoly` automatically configures **aaPanel**, **OzonPanel**, **Ubuntu/Debian**, **CentOS/AlmaLinux/RHEL**, **Nginx**, **Apache 2.4**, and **OpenLiteSpeed / LiteSpeed Enterprise** (including `PHP-FPM` `security.limit_extensions` and detached `lsphp` workers).

Ready-to-use manual templates are also available in [`configs/`](configs/):
- **Apache / OpenLiteSpeed `.htaccess`**: [`configs/apache/.htaccess`](configs/apache/.htaccess)
- **Nginx FastCGI**: [`configs/nginx/vinipoly-cme.conf`](configs/nginx/vinipoly-cme.conf)
- **OpenLiteSpeed Vhost**: [`configs/openlitespeed/vhost-cme.conf`](configs/openlitespeed/vhost-cme.conf)

---

## 5. Repository Structure

```text
vinipoly/
├── installer_vinipoly          # Precompiled Linux x86_64 Smart Installer & CLI Console
├── bin/
│   ├── vinipoly-encoder        # Precompiled Linux x86_64 Rust VPC3 Encoder CLI
│   └── vinipoly-decoder        # Precompiled Linux x86_64 Rust Recovery Decoder CLI
├── release-so/
│   ├── php73/vinipoly.so       # Native Zend Extension for PHP 7.3
│   ├── php74/vinipoly.so       # Native Zend Extension for PHP 7.4
│   ├── php80/vinipoly.so       # Native Zend Extension for PHP 8.0
│   ├── php81/vinipoly.so       # Native Zend Extension for PHP 8.1
│   ├── php82/vinipoly.so       # Native Zend Extension for PHP 8.2
│   ├── php83/vinipoly.so       # Native Zend Extension for PHP 8.3
│   ├── php84/vinipoly.so       # Native Zend Extension for PHP 8.4
│   └── php85/vinipoly.so       # Native Zend Extension for PHP 8.5
├── configs/                    # Nginx, Apache & OpenLiteSpeed configuration snippets
├── sdk/                        # Official Cloud CI/CD SDKs (PHP, JS/TS, Python, Go)
├── docs/                       # Bilingual Integration Guides (EN / VI)
├── SHA256SUMS.txt              # Cryptographic SHA-256 checksums for all binaries
├── release.manifest.json       # Machine-readable release metadata & raw URLs
└── version.txt                 # Current latest release tag (v3.0.0)
```

---

## License & Support

- **Product**: ViniPoly DRM Enterprise v3.0 — © **Chương Minh® Studio** ([https://chuongminh.com/vinipoly](https://chuongminh.com/vinipoly))
- **SDKs & Config Templates**: MIT License ([LICENSE](LICENSE)). Precompiled `vinipoly.so`, `vinipoly-encoder`, `vinipoly-decoder`, and `installer_vinipoly` binaries are proprietary commercial software distributed for licensed ViniPoly users.
