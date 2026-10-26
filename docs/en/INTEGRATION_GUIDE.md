# Comprehensive Technical & Integration Guide — ViniPoly DRM (v1.1.3 / Core v2.5.0)

Official technical documentation for server administrators, PHP developers, and DevOps teams integrating **ViniPoly DRM** (`https://vinipoly.cm.io.vn`).

## 1. Dual-Key Cryptographic Architecture & Zero-Disk Execution

ViniPoly DRM separates **Build-Time Authentication** from **Run-Time Execution**:

1. **Cloud API Key (`VP_...`)**:
   - Stored on your build machine or server at `/www/server/vinipoly.apikey` (`chmod 600`).
   - Authenticates encoding requests (`Local CLI Encoder` and `Cloud API`) and enforces IP/Domain firewall rules (`Allowed Hosts`).
2. **Local Recovery License Key (`REC_...`)**:
   - Stored on the target web server at `/www/server/vinipoly.license` (`chmod 644`, readable by `www`).
   - Used by the native Zend Extension (`vinipoly.so`) to decrypt and execute `.cme` files directly inside RAM.
3. **Including Encrypted `.cme` Files in PHP**:
   - Always use `__DIR__` when including or requiring `.cme` files so the C/Rust Zend loader resolves the exact physical path:
     ```php
     <?php
     // Recommended: Always use __DIR__ for exact path resolution in the C/Rust Zend Extension
     require_once __DIR__ . "/core_module.cme";
     ?>
     ```
4. **PHP `open_basedir` Requirement**:
   - If your hosting panel (such as aaPanel) uses `.user.ini` with `open_basedir`, ensure `/tmp/` and `/www/server/` are included:
     ```ini
     open_basedir=/www/wwwroot/your-domain.com/:/tmp/:/www/server/
     ```

## 2. Server Installation & Local Smart Encoder Workflow

### 2.1. One-Line Installation
```bash
curl -s -O https://cdn.chgm.in/install/v1.1.3/installer_vinipoly && chmod +x installer_vinipoly && ./installer_vinipoly
```

### 2.2. Encoding Projects Locally (`vinipoly` Menu `[3]`)
1. Run `vinipoly` in your server terminal and select **`[3] Mã hóa Dự án (Smart Local Encoder)`**.
2. Enter the path to your project folder (e.g., `/www/wwwroot/my-app`) or single `.php` file.
3. The CLI automatically:
   - Excludes third-party dependency directories (`vendor/`, `node_modules/`).
   - Detects existing `.cme` files and asks whether to overwrite or skip them.
   - Verifies your remaining file quota via `GET /api/drm/info`.
   - Compiles each `.php` file into an encrypted `.cme` file using `vinipoly-encoder`.
   - Prompts whether to securely remove the original plaintext `.php` files after successful encryption.

## 3. Web Server Configuration (`.cme` Native Execution & Clean URLs)

When you run `vinipoly` (or select Menu `[7]`), the CLI automatically configures **Nginx**, **Apache**, and **OpenLiteSpeed**. For manual or custom Docker setups, see the templates in `configs/`:

### 3.1. Apache / OpenLiteSpeed (`.htaccess`)
```apache
# Redirect direct browser requests from /page.cme to clean /page
RewriteCond %{THE_REQUEST} ^[A-Z]{3,}\s/([^.]+)\.cme [NC]
RewriteRule ^ %1 [R=301,L]

# Internally resolve /page to /page.cme if it exists
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME}\.cme -f
RewriteRule ^(.*)$ $1.cme [L]
```

### 3.2. PHP-FPM Extension Limit (`php-fpm.conf`)
Ensure `.cme` is added to `security.limit_extensions`:
```ini
security.limit_extensions = .php .php3 .php4 .php5 .php7 .cme
```

## 4. Cloud DRM REST API & CI/CD Automation

Base URL: `https://vinipoly.cm.io.vn/api/drm`

### 4.1. Check Account & Quota (`GET /api/drm/info`)
```bash
curl -s "https://vinipoly.cm.io.vn/api/drm/info?api_key=VP_your_api_key"
```
**Response:**
```json
{
  "plan": "pro",
  "quota": 142,
  "status": "active",
  "hosts": "*",
  "expire": "26/11/2026"
}
```

### 4.2. Update Firewall (`POST /api/drm/settings`)
```bash
curl -s -X POST "https://vinipoly.cm.io.vn/api/drm/settings" \
  -H "Content-Type: application/json" \
  -d '{"api_key": "VP_your_api_key", "status": "active", "allowed_hosts": "103.69.96.31, build.yourdomain.com"}'
```

### 4.3. Automated GitHub Actions Release Encryption
You can automatically encrypt your PHP source code whenever you publish a GitHub Release using our Python or Node.js SDK:
```yaml
name: Encrypt PHP Release with ViniPoly DRM
on:
  release:
    types: [published]
jobs:
  encrypt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Package PHP Source Files
        run: zip -r source.zip src/ -x "vendor/*" "node_modules/*"
      - name: Encrypt via ViniPoly Cloud SDK
        env:
          VINIPOLY_API_KEY: ${{ secrets.VINIPOLY_API_KEY }}
        run: |
          python3 -c "
          from sdk.python.vinipoly_sdk import ViniPolyClient
          import os
          client = ViniPolyClient(os.environ['VINIPOLY_API_KEY'])
          client.encode_project_zip('source.zip', 'Protected_by_ViniPoly.zip')
          "
```
