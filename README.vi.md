<div align="center">

# 🛡️ ViniPoly DRM v3.0
### Nền Tảng Mã Hóa Mã Nguồn PHP, Thực Thi 100% Trên RAM & Bảo Vệ Luồng Payload Thời Gian Thực

[![Phiên bản](https://img.shields.io/badge/Phiên%20bản-v3.0.0-0EA5E9?style=flat-square)](release.manifest.json)
[![Hỗ trợ PHP](https://img.shields.io/badge/PHP-7.3%20–%208.5%20(Native%20.so)-6366F1?style=flat-square)](#2-tải-trực-tiếp-binary-raw-linux-x86_64)
[![Web Servers](https://img.shields.io/badge/Web%20Servers-Nginx%20%7C%20Apache%20%7C%20OpenLiteSpeed-10B981?style=flat-square)](#4-cấu-hình-web-server--url-rút-gọn)
[![Hệ điều hành](https://img.shields.io/badge/Nền%20tảng-Linux%20x86__64-0F172A?style=flat-square)](#1-cài-đặt-nhanh-1-dòng-lệnh-linux-x86_64)
[![Phát triển bởi](https://img.shields.io/badge/Bởi-Chương%20Minh%20Studio-38BDF8?style=flat-square)](https://chuongminh.com/vinipoly)

**[🇻🇳 Tài Liệu Tiếng Việt](README.vi.md)** · **[🇬🇧 English Documentation](README.md)** · **[📦 Kiểm Tra SHA-256](SHA256SUMS.txt)** · **[📜 Release Manifest](release.manifest.json)** · **[📗 Hướng Dẫn Tích Hợp](docs/vi/INTEGRATION_GUIDE.md)**

</div>

---

## Giới thiệu

**ViniPoly DRM v3.0** (phát triển bởi **Chương Minh® Studio**) là hệ sinh thái bảo vệ bản quyền phần mềm thương mại, mã hóa mã nguồn PHP (`.php` → `.cme`) và bảo vệ kênh truyền dữ liệu thời gian thực dành cho các nền tảng SaaS, cổng thanh toán/SSO, hệ thống Laravel/Symfony, WordPress và ứng dụng doanh nghiệp.

Khác hoàn toàn với các công cụ làm rối mã truyền thống, **ViniPoly v3.0** đóng gói tệp PHP sang định dạng nhị phân xác thực **`CM_ENC v3` (`.cme`)** với bộ khóa độc lập trên từng tệp và nạp thẳng **100% vào bộ nhớ Zend Engine RAM** thông qua nhân C gốc (`vinipoly.so`) — **không dùng `eval()`**, **không sinh tệp tạm trên ổ cứng**, và **không can thiệp hay làm sai lệch bất kỳ tính năng PHP nào**.

---

## 1. Cài Đặt Nhanh 1 Dòng Lệnh (Linux x86_64)

Cài đặt trình điều khiển thông minh **ViniPoly v3.0** (`/usr/local/bin/vinipoly`), tự động nhận diện mọi phiên bản PHP (`7.3` đến `8.5`) và cấu hình đồng bộ Nginx / Apache / OpenLiteSpeed:

```bash
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/installer_vinipoly -o /usr/local/bin/vinipoly && chmod +x /usr/local/bin/vinipoly && vinipoly
```

### Tải trực tiếp Bộ Mã Hóa & Giải Mã CLI (Raw Binary)

```bash
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-encoder -o /usr/local/bin/vinipoly-encoder && chmod +x /usr/local/bin/vinipoly-encoder
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-decoder -o /usr/local/bin/vinipoly-decoder && chmod +x /usr/local/bin/vinipoly-decoder
```

### Cài thủ công tệp `.so` cho từng bản PHP (Ví dụ: PHP 8.3)

```bash
EXT_DIR=$(php-config --extension-dir)
curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php83/vinipoly.so -o "${EXT_DIR}/vinipoly.so"
chmod 755 "${EXT_DIR}/vinipoly.so"
```

---

## 2. Tải Trực Tiếp Binary Raw (Linux x86_64)

Toàn bộ tệp thực thi chính thức được lưu trữ dưới dạng **Git Raw Binary nguyên bản (không qua Git LFS)**, cho phép tải trực tiếp tốc độ cao bằng `curl` / `wget` trên mọi máy chủ sản xuất và CI/CD.

| Thành phần | Mô tả & Phiên bản đích | Dung lượng | SHA-256 (Rút gọn) | Tải Trực Tiếp (Raw) |
| :--- | :--- | :---: | :---: | :--- |
| **`installer_vinipoly`** | Trình cài đặt & Điều khiển thông minh | 48.2 KB | `3ecd7625f12f887f…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/installer_vinipoly) |
| **`bin/vinipoly-encoder`** | Bộ mã hóa Rust VPC3 & AST CLI | 8.34 MB | `ec520eba7cc32617…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-encoder) |
| **`bin/vinipoly-decoder`** | Bộ khôi phục mã nguồn chính chủ CLI | 8.40 MB | `b8ca185264e809f3…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/bin/vinipoly-decoder) |
| **`release-so/php73/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 7.3** | 413.5 KB | `69d7e0b20adc2b93…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php73/vinipoly.so) |
| **`release-so/php74/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 7.4** | 412.7 KB | `cfe0e8178c0a845f…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php74/vinipoly.so) |
| **`release-so/php80/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 8.0** | 411.9 KB | `aa84c298bff392ff…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php80/vinipoly.so) |
| **`release-so/php81/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 8.1** | 414.1 KB | `cbff8be3467cf548…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php81/vinipoly.so) |
| **`release-so/php82/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 8.2** | 417.6 KB | `35ebb6d7d4227918…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php82/vinipoly.so) |
| **`release-so/php83/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 8.3** | 418.0 KB | `3aa93bb17d4da660…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php83/vinipoly.so) |
| **`release-so/php84/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 8.4** | 421.9 KB | `d88746198942c8ae…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php84/vinipoly.so) |
| **`release-so/php85/vinipoly.so`** | Nhân Zend thực thi RAM — **PHP 8.5** | 422.8 KB | `582e5c811c15f951…` | [Tải Raw](https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/release-so/php85/vinipoly.so) |

> **Kiểm tra toàn vẹn SHA-256**:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/chuongminhofficial/vinipoly/main/SHA256SUMS.txt | sha256sum -c --ignore-missing
> ```

---

## 3. Điểm Mới Trong ViniPoly v3.0

- **Thực thi Nhân C Gốc 100% Không `eval()` (`vinipoly.so`)**: Biên dịch trực tiếp opcode trên RAM cho toàn dải **PHP 7.3 – 8.5** với tốc độ tương đương PHP thuần.
- **Tương thích Trong Suốt 100% Hệ Sinh Thái PHP**: Tự động ánh xạ `require`, `include`, Composer PSR-4 Autoloader, `file_exists()`, `is_file()` và `is_readable()` từ `.php` sang `.cme` mà không cần sửa đổi mã nguồn gốc.
- **Mã Hóa Hằng Số Nhạy Cảm Bằng Bộ Phân Tích AST (`vinipoly-encoder`)**: Tự động niêm phong chuỗi kết nối DB, mật khẩu, khóa API/JWT/Webhook vào kho khóa riêng từng tệp; tự động giữ nguyên tài nguyên tĩnh (`.js`, `.css`, `.png`, `.json`, `.htaccess`), Heredoc/Nowdoc, `declare(strict_types=1)` và PHP 8 Attributes/Enums.
- **Bảo Vệ Luồng Payload 2 Chiều & Ẩn Cấu Trúc HTML**: Mã hóa thông minh kênh `fetch` / `XMLHttpRequest` mà không gây xung đột với OAuth2, Webhook, Cloudflare Turnstile hay SDK bên thứ ba.
- **Lớp Phủ F12 Không Khung Viền — Đa Ngôn Ngữ & Hỗ Trợ RTL**: Thiết kế Midnight Horizon hiện đại trong `Closed Shadow DOM`, tích hợp sẵn **11 ngôn ngữ** kèm chế độ **RTL gốc** (Ả Rập, Ba Tư, Do Thái), tự động khôi phục phiên làm việc tức thì không tải lại trang.
- **Xác Thực Bot Tìm Kiếm FCrDNS Chuẩn SEO**: Đảm bảo Googlebot, Bingbot, Applebot thu thập đầy đủ dữ liệu SEO đồng thời chặn giả mạo User-Agent.
- **Khôi Phục Nguyên Bản 100% (`vinipoly-decoder`)**: Khôi phục chính xác từng bit từ `.cme` về `.php` bằng License Key chính chủ ngay cả khi đã xoay vòng API Key.

---

## 4. Cấu Hình Web Server & URL Rút Gọn

Lệnh `vinipoly` tự động cấu hình trọn gói cho **aaPanel**, **OzonPanel**, **Ubuntu/Debian**, **CentOS/AlmaLinux/RHEL**, **Nginx**, **Apache 2.4** và **OpenLiteSpeed / LiteSpeed Enterprise**.

Các mẫu cấu hình thủ công nằm tại thư mục [`configs/`](configs/):
- **Apache / OpenLiteSpeed `.htaccess`**: [`configs/apache/.htaccess`](configs/apache/.htaccess)
- **Nginx FastCGI**: [`configs/nginx/vinipoly-cme.conf`](configs/nginx/vinipoly-cme.conf)
- **OpenLiteSpeed Vhost**: [`configs/openlitespeed/vhost-cme.conf`](configs/openlitespeed/vhost-cme.conf)

---

## Bản Quyền & Liên Hệ

- **Sản phẩm**: ViniPoly DRM Enterprise v3.0 — © **Chương Minh® Studio** ([https://chuongminh.com/vinipoly](https://chuongminh.com/vinipoly))
- **SDK & Cấu hình mẫu**: Giấy phép MIT ([LICENSE](LICENSE)). Các tệp thực thi `vinipoly.so`, `vinipoly-encoder`, `vinipoly-decoder` và `installer_vinipoly` là phần mềm thương mại thuộc bản quyền Chương Minh® Studio.
