# Tài Liệu Kỹ Thuật & Hướng Dẫn Tích Hợp Toàn Diện — ViniPoly DRM (v1.1.3 / Core v2.5.0)

Tài liệu kỹ thuật chính thức dành cho quản trị viên máy chủ, lập trình viên PHP và đội ngũ DevOps tích hợp nền tảng **ViniPoly DRM** (`https://vinipoly.cm.io.vn`).

## 1. Kiến Trúc Khóa Kép & Cơ Chế Thực Thi Trực Tiếp Trong RAM

Hệ thống ViniPoly DRM tách biệt rõ ràng giữa **Khóa xác thực khi Mã hóa (Build-Time)** và **Khóa giấy phép khi Chạy ứng dụng (Run-Time)**:

1. **Khóa API Đám Mây (`VP_...` — Cloud API Key)**:
   - Lưu tại `/www/server/vinipoly.apikey` (`chmod 600`).
   - Dùng để xác thực quyền mã hóa dự án qua `vinipoly` CLI hoặc Cloud API và kiểm tra tường lửa `Allowed Hosts`.
2. **Khóa Giấy Phép Cục Bộ (`REC_...` — Recovery License Key)**:
   - Lưu trên máy chủ chạy Web tại `/www/server/vinipoly.license` (`chmod 644`).
   - Được module `vinipoly.so` đọc trực tiếp để giải mã và thực thi tệp `.cme` trong bộ nhớ RAM.
3. **Quy Tắc Gọi Tệp `.cme` Trong PHP (`include` / `require`)**:
   - Luôn sử dụng hằng số `__DIR__` khi nhúng tệp `.cme` để lõi C/Rust định vị chính xác đường dẫn vật lý trên ổ cứng:
     ```php
     <?php
     // Bắt buộc dùng __DIR__ để Lõi C định vị được chính xác tệp tin trên đĩa cứng
     include __DIR__ . "/source_test.cme";
     ?>
     ```
4. **Cấu Hình `open_basedir` Trong `.user.ini`**:
   - Nếu máy chủ bật giới hạn `open_basedir`, hãy đảm bảo cho phép truy cập `/tmp/` và `/www/server/`:
     ```ini
     open_basedir=/www/wwwroot/your-domain.com/:/tmp/:/www/server/
     ```

## 2. Hướng Dẫn Cài Đặt & Mã Hóa Cục Bộ Qua `vinipoly` CLI

### 2.1. Lệnh Cài Đặt Duy Nhất Cho Khách Hàng
```bash
curl -s -O https://cdn.chgm.in/install/v1.1.3/installer_vinipoly && chmod +x installer_vinipoly && ./installer_vinipoly
```

### 2.2. Quy Trình Mã Hóa Dự Án Thông Minh (Phím `[3]`)
1. Gõ lệnh `vinipoly` trên Terminal và chọn phím **`[3] Mã hóa Dự án (Smart Local Encoder)`**.
2. Nhập đường dẫn thư mục dự án (ví dụ `/www/wwwroot/my-website`) hoặc đường dẫn 1 tệp `.php` lẻ.
3. Hệ thống sẽ tự động:
   - Loại trừ các thư mục thư viện ngoài (`vendor/`, `node_modules/`).
   - Phát hiện các tệp `.cme` đã tồn tại để hỏi ý kiến ghi đè hoặc bỏ qua (tránh lãng phí lượt mã hóa).
   - Kiểm tra số lượt hạn ngạch còn lại trên Cloud trước khi chạy.
   - Thực thi `vinipoly-encoder` biên dịch `.php` sang `.cme` ngay tại máy chủ.
   - Hỏi xác nhận xóa tận gốc các tệp `.php` mã nguồn gốc sau khi đã tạo `.cme` thành công.

## 3. Cấu Hình Định Tuyến Web Server & Làm Sạch URL (`.cme`)

Khi chạy `vinipoly` (hoặc chọn phím `[7]`), hệ thống tự động cấu hình **Nginx**, **Apache** và **OpenLiteSpeed**. Nếu bạn cấu hình thủ công, có thể sử dụng bộ mẫu trong thư mục `configs/`:

### 3.1. Cấu Hình `.htaccess` (Apache / OpenLiteSpeed)
```apache
# Chuyển hướng trình duyệt từ file có đuôi .cme sang không đuôi (Để làm sạch URL)
RewriteCond %{THE_REQUEST} ^[A-Z]{3,}\s/([^.]+)\.cme [NC]
RewriteRule ^ %1 [R=301,L]

# Xử lý ngầm: Khi khách truy cập /index, hệ thống tự hiểu là chạy file /index.cme
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME}\.cme -f
RewriteRule ^(.*)$ $1.cme [L]
```

## 4. Tích Hợp Cloud DRM REST API & Tự Động Hóa CI/CD

Endpoint gốc: `https://vinipoly.cm.io.vn/api/drm`

### 4.1. Kiểm Tra Tài Khoản & Hạn Ngạch (`GET /api/drm/info`)
```bash
curl -s "https://vinipoly.cm.io.vn/api/drm/info?api_key=VP_your_api_key"
```
**Phản hồi JSON:**
```json
{
  "plan": "pro",
  "quota": 142,
  "status": "active",
  "hosts": "*",
  "expire": "26/11/2026"
}
```

### 4.2. Cập Nhật Tường Lửa Allowed Hosts (`POST /api/drm/settings`)
```bash
curl -s -X POST "https://vinipoly.cm.io.vn/api/drm/settings" \
  -H "Content-Type: application/json" \
  -d '{"api_key": "VP_your_api_key", "status": "active", "allowed_hosts": "103.69.96.31, server.domain.com"}'
```
