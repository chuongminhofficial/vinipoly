# Security Policy / Chính Sách Bảo Mật — ViniPoly DRM

## 🇬🇧 English
* **Never commit live credentials**: Do not commit your `VP_...` API Key, `REC_...` Recovery License Key, `.pem` keys, `.env` files, or `.sql` database dumps to public repositories.
* **Enable Allowed Hosts Firewall**: Always restrict your `VP_...` API Key to your build server's public IP address via `POST /api/drm/settings` or the ViniPoly Cloud Console.
* **File Permissions on Linux Servers**: Ensure `/www/server/vinipoly.apikey` has `chmod 600` (root-only) and `/www/server/vinipoly.license` has `chmod 644`.

## 🇻🇳 Tiếng Việt
* **Bảo mật Khóa & Mã nguồn**: Tuyệt đối không đưa khóa `VP_...` (API Key), `REC_...` (Recovery Key), khóa `.pem`, tệp `.env` hoặc cơ sở dữ liệu `.sql` lên kho lưu trữ công khai.
* **Kích hoạt Tường lửa Allowed Hosts**: Luôn giới hạn địa chỉ IP máy chủ được phép sử dụng API Key của bạn trong mục **API & Bảo mật** trên ViniPoly Console.
* **Phân quyền tệp trên VPS**: Đảm bảo `/www/server/vinipoly.apikey` để quyền `600` và `/www/server/vinipoly.license` để quyền `644`.
