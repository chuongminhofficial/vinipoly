<div align="center">

# 🛡️ ViniPoly DRM — Nền Tảng Mã Hóa Bảo Vệ Mã Nguồn PHP & Thực Thi Trực Tiếp Trong RAM

**Mã Hóa Quân Sự AES-256-GCM (`.php` $\rightarrow$ `.cme`), Giải Mã Thực Thi 100% Trong RAM (Zero-Disk Zend Extension) & Bộ SDK Đám Mây Đa Ngôn Ngữ**

[![Phiên bản CLI](https://img.shields.io/badge/CLI%20Console-v1.1.3-0A66C2?style=flat-square)](#3-cài-đặt-nhanh-trên-máy-chủ-linux-1-dòng-lệnh-duy-nhất)
[![Lõi Hệ Thống](https://img.shields.io/badge/Core%20Engine-v2.5.0%20Production-10B981?style=flat-square)](#)
[![Hỗ trợ PHP](https://img.shields.io/badge/PHP-7.3%20--%208.3%20(Zend%20.so)-6366F1?style=flat-square)](#1-kiến-trúc-bảo-mật-cốt-lõi)
[![Web Servers](https://img.shields.io/badge/Web%20Servers-Nginx%20%7C%20Apache%20%7C%20OpenLiteSpeed-F59E0B?style=flat-square)](#2-cấu-trúc-kho-lưu-trữ)
[![Giấy phép: MIT](https://img.shields.io/badge/SDK%20License-MIT-22C55E?style=flat-square)](LICENSE)

**[🇬🇧 English Documentation](README.md)** · **[🇻🇳 Tài Liệu Tiếng Việt](README.vi.md)** · **[📘 Full Integration Guide (EN)](docs/en/INTEGRATION_GUIDE.md)** · **[📗 Tài Liệu Tích Hợp (VI)](docs/vi/INTEGRATION_GUIDE.md)** · **[🚀 Bộ Sưu Tập Postman](postman/)**

</div>

## Giới Thiệu Tổng Quan

Chào mừng bạn đến với kho lưu trữ GitHub công khai chính thức của **ViniPoly DRM** (phát triển bởi **Chương Minh® Studio**). ViniPoly DRM là nền tảng mã hóa bảo vệ bản quyền mã nguồn PHP chuyên nghiệp cấp doanh nghiệp, giúp chống đánh cắp mã nguồn, chống dịch ngược (anti-decompilation) và kiểm soát giấy phép triển khai cho các hệ thống SaaS, Website thương mại, WordPress Plugin/Theme và ứng dụng Laravel/Symfony.

Khác biệt hoàn toàn với các công cụ làm rối mã (obfuscator) truyền thống hay các trình mã hóa tạo tệp tạm trên ổ cứng, **ViniPoly DRM** biên dịch và mã hóa tệp `.php` sang định dạng nhị phân **`.cme` (Chương Minh Encrypted)** bằng thuật toán **AES-256-GCM**, sau đó giải mã và thực thi **100% trực tiếp trong bộ nhớ RAM** thông qua Zend Extension (`vinipoly.so`) viết bằng C/Rust.

> **Lưu ý Kiến trúc & Bảo mật**: Kho lưu trữ công khai này cung cấp **Bộ SDK Đám Mây Chính Thức (JS/TS, PHP, Python, Go), Trình điều khiển CLI dành cho khách hàng, Cấu hình mẫu Web Server, Bộ kiểm thử thực thi RAM và Postman Collection**. Lõi biên dịch Rust (`vinipoly-encoder`), Zend Extension (`vinipoly.so`) và Cổng Cloud DRM (`https://vinipoly.cm.io.vn`) là tài sản phần mềm thương mại độc quyền của Chương Minh® Studio.

## 1. Kiến Trúc Bảo Mật Cốt Lõi

* **Thực Thi 100% Trong RAM (Zero-Disk Execution — `vinipoly.so`)**: Toàn bộ quá trình giải mã và nạp Opcode vào Zend Engine diễn ra hoàn toàn trong RAM, tuyệt đối không ghi bất kỳ dữ liệu mã nguồn `.php` giải mã nào ra đĩa cứng.
* **Cơ Chế Bảo Vệ Khóa Kép (`AES-256-GCM` + Dual-Key Binding)**:
  * **Khóa API Đám Mây (`VP_...`)**: Xác thực quyền mã hóa của lập trình viên với cổng Cloud DRM (`https://vinipoly.cm.io.vn/api/drm`) kèm tường lửa giới hạn IP/Tên miền (`Allowed Hosts`).
  * **Khóa Giấy Phép Cục Bộ (`REC_...` — Recovery License Key)**: Lưu tại `/www/server/vinipoly.license` (`chmod 644`) trên máy chủ đích để cấp quyền cho lõi `vinipoly.so` giải mã thực thi tệp `.cme` trong RAM.
* **Frontend Cloaking & Tối Ưu Hóa SEO Tuyệt Đối**: Bảo vệ mã nguồn đầu ra nhưng vẫn thân thiện 100% với Googlebot và các công cụ tìm kiếm.
* **Tương Thích Đa Nền Tảng**:
  * **Phiên bản PHP**: Hỗ trợ đầy đủ PHP `7.3`, `7.4`, `8.0`, `8.1`, `8.2`, `8.3` (`php-fpm`, `php-cli`, `lsphp`).
  * **Web Server**: Tự động định tuyến `.cme` trên **Nginx**, **Apache**, **OpenLiteSpeed** và **aaPanel**.

## 2. Cấu Trúc Kho Lưu Trữ

```text
vinipoly-drm/
├── cli/
│   └── install-public.sh                        # Trình cài đặt & Bảng điều khiển ViniPoly CLI cho Linux (v1.1.3)
├── configs/
│   ├── apache/.htaccess                         # Cấu hình ẩn đuôi .cme & định tuyến URL sạch cho Apache/OLS
│   ├── nginx/vinipoly-cme.conf                  # Cấu hình Nginx FastCGI chạy song song .php và .cme
│   └── php/.user.ini.example                    # Cấu hình mẫu open_basedir tương thích ViniPoly
├── docs/
│   ├── en/INTEGRATION_GUIDE.md                  # Tài liệu tích hợp & Tham chiếu API chi tiết (Tiếng Anh)
│   └── vi/INTEGRATION_GUIDE.md                  # Tài liệu tích hợp & Tham chiếu API chi tiết (Tiếng Việt)
├── examples/
│   ├── php-ram-test/                            # Bộ kiểm thử thực thi RAM (source_test.php & testcore.php)
│   ├── js_quickstart.js                         # Ví dụ tích hợp nhanh Node.js / TypeScript SDK
│   ├── php_quickstart.php                       # Ví dụ tích hợp nhanh PHP SDK
│   ├── python_quickstart.py                     # Ví dụ tích hợp nhanh Python SDK
│   └── go_quickstart.go                         # Ví dụ tích hợp nhanh Go SDK
├── postman/
│   ├── vinipoly_drm_postman_collection.en.json  # Postman Collection v2.1.0 (Bản Tiếng Anh)
│   └── vinipoly_drm_postman_collection.vi.json  # Postman Collection v2.1.0 (Bản Tiếng Việt)
├── sdk/
│   ├── js/                                      # JavaScript / TypeScript SDK (vinipoly_sdk.js + .d.ts)
│   ├── php/                                     # PHP 7.4/8.x SDK (ViniPolySDK.php + composer.json)
│   ├── python/                                  # Python 3.8+ SDK (vinipoly_sdk.py - Không phụ thuộc thư viện ngoài)
│   └── go/                                      # Go 1.18+ SDK (vinipoly_sdk.go + go.mod)
├── README.md                                    # Tài liệu giới thiệu chính (Tiếng Anh - Mặc định GitHub)
├── README.vi.md                                 # Tài liệu giới thiệu chính (Tiếng Việt)
├── SECURITY.md                                  # Chính sách bảo mật song ngữ
├── CONTRIBUTING.md                              # Hướng dẫn đóng góp song ngữ
├── CHANGELOG.md                                 # Lịch sử phiên bản
└── LICENSE                                      # Giấy phép MIT (Dành cho bộ Client SDK & Configs)
```

## 3. Cài Đặt Nhanh Trên Máy Chủ Linux (1 Dòng Lệnh Duy Nhất)

Chạy câu lệnh duy nhất dưới đây với quyền `root` trên máy chủ VPS/Server Linux (Ubuntu, Debian, CentOS, AlmaLinux sử dụng aaPanel) để tự động cài đặt ViniPoly CLI, gắn giáp bảo mật `vinipoly.so` cho mọi phiên bản PHP (`7.3`–`8.3`) và định tuyến Web Server:

```bash
curl -s -O https://cdn.chgm.in/install/v1.1.3/installer_vinipoly && chmod +x installer_vinipoly && ./installer_vinipoly
```

Sau khi cài đặt xong, bất cứ lúc nào bạn chỉ cần gõ lệnh `vinipoly` trên Terminal để mở Bảng điều khiển trung tâm:

| Phím | Chức năng trên Console | Mô tả chi tiết |
| :---: | :--- | :--- |
| **`[1]`** | **Cài đặt lại Lõi PHP (Install Core)** | Tự động quét `/www/server/php/*` (PHP 7.3–8.3), tải `vinipoly.so` từ CDN và khởi động lại `php-fpm` / `lsphp`. |
| **`[2]`** | **Quản lý Khóa (Key Management)** | Cập nhật `Recovery Key` (`/www/server/vinipoly.license`) hoặc `API Key` (`/www/server/vinipoly.apikey`). |
| **`[3]`** | **Mã hóa Dự án (Smart Local Encoder)** | Tự động quét thư mục dự án (bỏ qua `vendor/`, `node_modules/`), kiểm tra hạn ngạch, mã hóa `.php` $\rightarrow$ `.cme` cục bộ siêu tốc và hỗ trợ dọn dẹp file `.php` gốc. |
| **`[4]`** | **Kiểm tra trạng thái máy chủ (Services)** | Kiểm tra trạng thái Nginx/Apache/OpenLiteSpeed, lõi `.so` trên từng bản PHP và tự động sửa quyền file giấy phép (`644`). |
| **`[5]`** | **Tra cứu thông tin API Key (Cloud Info)** | Kết nối Cloud hiển thị Gói dịch vụ, Hạn ngạch còn lại, Tường lửa Allowed Hosts và Ngày hết hạn. |
| **`[6]`** | **Cập nhật ViniPoly (Auto-Update)** | Kiểm tra và nâng cấp tự động trình điều khiển `vinipoly` lên phiên bản mới nhất từ CDN. |
| **`[7]`** | **Định tuyến lại Web Server** | Cấu hình tự động Nginx, Apache và OpenLiteSpeed để chạy trực tiếp đuôi `.cme`. |

## 4. Hướng Dẫn Sử Dụng Bộ SDK Đám Mây (4 Ngôn Ngữ)

### 4.1. JavaScript / TypeScript (`sdk/js/vinipoly_sdk.js`)
```javascript
const { ViniPolyClient } = require('./sdk/js/vinipoly_sdk.js');

const client = new ViniPolyClient({
  apiKey: process.env.VINIPOLY_API_KEY || 'VP_your_api_key_here',
});

// 1. Kiểm tra hạn ngạch (Quota) & gói dịch vụ
const info = await client.getAccountInfo();
console.log(`Gói: ${info.plan.toUpperCase()} | Còn lại: ${info.quota} files`);

// 2. Tự động cắt chunk 10MB, tải lên Cloud và nhận về file ZIP đã mã hóa (.cme)
await client.encodeProjectZip('./dist/source.zip', './dist/Protected_by_ViniPoly.zip');
```

### 4.2. PHP (`sdk/php/ViniPolySDK.php`)
```php
<?php
require_once __DIR__ . '/sdk/php/ViniPolySDK.php';

use ViniPolyDRM\ViniPolyClient;

$client = new ViniPolyClient(getenv('VINIPOLY_API_KEY') ?: 'VP_your_api_key_here');

$info = $client->getAccountInfo();
echo "Hạn ngạch còn lại: {$info['quota']} files\n";

// Mã hóa gói ZIP dự án trên đám mây và lưu thành Protected_by_ViniPoly.zip
$client->encodeProjectZip(__DIR__ . '/source.zip', __DIR__ . '/Protected_by_ViniPoly.zip');
```

### 4.3. Python (`sdk/python/vinipoly_sdk.py`)
```python
from sdk.python.vinipoly_sdk import ViniPolyClient

client = ViniPolyClient(api_key="VP_your_api_key_here")

info = client.get_account_info()
print(f"Gói: {info['plan']} | Hạn ngạch: {info['quota']} files")

# Tải lên theo từng phần (Chunked) & mã hóa sang .cme trên Cloud
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
	fmt.Printf("Gói: %s | Hạn ngạch: %d files\n", info.Plan, info.Quota)

	_ = client.EncodeProjectZip(ctx, "source.zip", "Protected_by_ViniPoly.zip")
}
```

## 5. Bảng Tham Chiếu Cloud DRM API (`https://vinipoly.cm.io.vn/api/drm`)

| STT | Phương thức & Đường dẫn | Xác thực | Tham số / Body | Chức năng |
| :---: | :--- | :--- | :--- | :--- |
| 01 | `GET /api/drm/info` | `?api_key=VP_...` | Query `api_key` | Tra cứu gói cước (`plan`), số lượt còn lại (`quota`), trạng thái (`status`), `hosts` và hạn dùng (`expire`). |
| 02 | `GET /api/drm/settings` | `?api_key=VP_...` | Query `api_key` | Lấy trạng thái khóa (`active`/`inactive`) và danh sách IP/Tên miền trong `allowed_hosts`. |
| 03 | `POST /api/drm/settings` | JSON `api_key` | `{"api_key", "status", "allowed_hosts"}` | Bật/tắt khóa API và cập nhật danh sách tường lửa `Allowed Hosts` (`*` hoặc danh sách IP/Domain). |
| 04 | `GET /api/drm/history` | `?api_key=VP_...` | Query `api_key` | Lấy lịch sử 30 giao dịch mã hóa gần nhất (`Local CLI Encoder`, `Cloud API`). |
| 05 | `POST /api/drm/deduct-quota` | JSON `api_key` | `{"api_key", "file_count"}` | Khấu trừ hạn ngạch khi thực hiện mã hóa cục bộ qua công cụ `vinipoly` CLI. |
| 06 | `POST /api/drm/upload-chunk` | Multipart Form | `upload_id`, `chunk` (10MB) | Tải lên từng phân mảnh (Chunk) của gói ZIP mã nguồn lên không gian xử lý đám mây. |
| 07 | `POST /api/drm/cloud-encode` | Multipart Form | `upload_id`, `api_key` | Kiểm tra tường lửa `Allowed Hosts` & hạn ngạch, biên dịch `.php` $\rightarrow$ `.cme` và trả về file `Protected_by_ViniPoly.zip`. |

## 6. Các Gói Dịch Vụ & Chính Sách Bảo Vệ Quyền Lợi Khách Hàng

* **Các gói định mức**: **Trial** (`3 files`), **Free** (`30 files`), **Pro** (`150 files`), **Enterprise** (`520 files`) và **Pay-To-Go** (`Cộng dồn lượt vĩnh viễn không giới hạn thời gian`).
* **Chính sách Cứu hộ & Tự động Hoàn bù Hạn ngạch (Auto-Refund Quota)**: Trong trường hợp khách hàng gặp sự cố mất mã nguồn gốc và yêu cầu hỗ trợ khôi phục chính chủ từ quản trị viên, hệ thống sẽ tự động **hoàn bù lại đúng 100% số lượt mã hóa** vào tài khoản và cấp mới khóa `Recovery Key` an toàn để khách hàng mã hóa lại dự án mà không phát sinh thêm chi phí.

## Giấy Phép (License)

Bộ thư viện Client SDK, cấu hình mẫu Web Server và ví dụ tích hợp trong kho lưu trữ này được phát hành theo giấy phép [MIT License](LICENSE).
