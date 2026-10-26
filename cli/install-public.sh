#!/bin/bash
# =====================================================================
#  [ VINIPOLY ENTERPRISE CLI CONSOLE (PUBLIC CLIENT EDITION v1.1.3) ]
#  Official Server Installer & Local Smart Encoder Dashboard
#  Website: https://vinipoly.cm.io.vn | CDN: https://cdn.chgm.in
# =====================================================================

APP_VERSION="v1.1.3"
CDN_BASE="https://cdn.chgm.in"
API_BASE="https://vinipoly.cm.io.vn/api/drm"
LICENSE_FILE="/www/server/vinipoly.license"
API_KEY_FILE="/www/server/vinipoly.apikey"
BIN_PATH="/usr/local/bin/vinipoly"

# --- UI COLOR PALETTE ---
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'
NC='\033[0m'

# =================================================================
# CORE SYSTEM HANDLERS
# =================================================================

check_services() {
    clear
    echo -e "${C_CYAN}========================================================${NC}"
    echo -e "${C_WHITE}    [ KIỂM TRA TRẠNG THÁI HỆ THỐNG & DỊCH VỤ ]${NC}"
    echo -e "${C_CYAN}========================================================${NC}\n"

    echo -e "${C_YELLOW}[1] Trạng thái Web Server:${NC}"
    [ -d "/www/server/nginx" ] && (pgrep -x "nginx" >/dev/null && echo -e "  - Nginx: ${C_GREEN}Running${NC}" || echo -e "  - Nginx: ${C_RED}Stopped${NC}")
    [ -d "/www/server/apache" ] && (pgrep -x "httpd" >/dev/null && echo -e "  - Apache: ${C_GREEN}Running${NC}" || echo -e "  - Apache: ${C_RED}Stopped${NC}")
    [ -d "/usr/local/lsws" ] && (pgrep "litespeed" >/dev/null || pgrep "lshttpd" >/dev/null && echo -e "  - OpenLiteSpeed: ${C_GREEN}Running${NC}" || echo -e "  - OpenLiteSpeed: ${C_RED}Stopped${NC}")

    echo -e "\n${C_YELLOW}[2] Trạng thái Module ViniPoly (PHP):${NC}"
    if [ -d "/www/server/php" ]; then
        for VER_DIR in /www/server/php/*; do
            VER=$(basename "$VER_DIR")
            if [[ "$VER" =~ ^[0-9]+$ ]] && [ "$VER" -ge 73 ]; then
                EXT_DIR=$(/www/server/php/${VER}/bin/php-config --extension-dir 2>/dev/null)
                if [ -f "${EXT_DIR}/vinipoly.so" ]; then
                    echo -e "  - PHP ${VER}: ${C_GREEN}Đã cài đặt lõi (.so)${NC}"
                else
                    echo -e "  - PHP ${VER}: ${C_GRAY}Chưa cài đặt${NC}"
                fi
            fi
        done
    fi

    echo -e "\n${C_YELLOW}[3] Thông tin hệ thống ViniPoly DRM:${NC}"
    echo -e "  - Phiên bản CLI: ${C_GREEN}${APP_VERSION}${NC}"

    if [ -f "$LICENSE_FILE" ]; then
        PERM=$(stat -c "%a" "$LICENSE_FILE")
        if [ "$PERM" == "644" ]; then
            echo -e "  - Giấy phép Cục bộ (Local): ${C_GREEN}Hợp lệ (Quyền 644)${NC}"
        else
            echo -e "  - Giấy phép Cục bộ (Local): ${C_RED}Cảnh báo quyền ($PERM) - Đã tự động sửa...${NC}"
            chmod 644 "$LICENSE_FILE"
        fi
    else
        echo -e "  - Giấy phép Cục bộ (Local): ${C_RED}Chưa cấu hình${NC}"
    fi

    if [ -f "$API_KEY_FILE" ]; then
        echo -e "  - Khóa API Cloud (API Key) : ${C_GREEN}Đã lưu cục bộ${NC}"
    else
        echo -e "  - Khóa API Cloud (API Key) : ${C_GRAY}Chưa cấu hình${NC}"
    fi

    echo -e "\n${C_CYAN}========================================================${NC}"
}

reroute_webserver() {
    echo -e "\n${C_CYAN}[+] Tự động định tuyến tên miền (.cme)...${NC}"

    # Nginx
    if [ -d "/www/server/nginx/conf" ]; then
        for CONF_FILE in /www/server/nginx/conf/enable-php-*.conf; do
            [ -f "$CONF_FILE" ] && sed -i 's/\\\.php(/\\\.(php|cme)(/g' "$CONF_FILE" && sed -i 's/\\\.php\$/\\\.(php|cme)\$/g' "$CONF_FILE"
        done
        if [ -d "/www/server/panel/vhost/nginx" ]; then find /www/server/panel/vhost/nginx -type f -name "*.conf" -exec sed -i -E 's/\\\.php\$/\\.(php|cme)\$/g' {} + ; fi
        /etc/init.d/nginx reload > /dev/null 2>&1
        echo -e " ${C_GREEN}[OK] Nginx đã sẵn sàng.${NC}"
    fi

    # Apache
    if [ -d "/www/server/apache/conf" ]; then
        echo -e "   -> Đang chèn Handler .cme vào Apache..."
        APACHE_CONF="/www/server/apache/conf/httpd.conf"
        if [ -f "$APACHE_CONF" ] && ! grep -q "x-httpd-php .cme" "$APACHE_CONF"; then
            sed -i 's/AddType application\/x-httpd-php .php/AddType application\/x-httpd-php .php .cme/g' "$APACHE_CONF"
        fi
        if [ -d "/www/server/panel/vhost/apache" ]; then
            for vhost in /www/server/panel/vhost/apache/*.conf; do
                if [ -f "$vhost" ]; then
                    sed -i 's/FilesMatch "\\.php\$"/FilesMatch "\\.(php|cme)\$"/g' "$vhost"
                    sed -i 's/FilesMatch "\\.(php|php\[0-9\])\$"/FilesMatch "\\.(php|php[0-9]|cme)\$"/g' "$vhost"
                fi
            done
        fi
        /etc/init.d/httpd reload > /dev/null 2>&1
        echo -e " ${C_GREEN}[OK] Apache đã sẵn sàng chạy .cme${NC}"
    fi

    # OpenLiteSpeed
    OLS_CONF="/usr/local/lsws/conf/httpd_config.xml"
    OLS_MIME="/usr/local/lsws/conf/mime.properties"
    if [ -d "/usr/local/lsws/conf" ]; then
        if [ -f "$OLS_CONF" ]; then
            if ! grep -q "<suffix>cme</suffix>" "$OLS_CONF" && ! grep -q "php,cme" "$OLS_CONF"; then sed -i 's/<suffix>php<\/suffix>/<suffix>php,cme<\/suffix>/g' "$OLS_CONF"; fi
            if ! grep -q "<ext>cme</ext>" "$OLS_CONF" && ! grep -q "php,cme" "$OLS_CONF"; then sed -i 's/<ext>php<\/ext>/<ext>php,cme<\/ext>/g' "$OLS_CONF"; fi
        fi
        if [ -f "$OLS_MIME" ]; then
            if ! grep -q "=cme" "$OLS_MIME"; then sed -i 's/application\/x-httpd-php\s*=.*/application\/x-httpd-php          = php, php3, php4, php5, php7, phtml, cme/g' "$OLS_MIME"; fi
        fi
        if [ -d "/www/server/panel/vhost/openlitespeed" ]; then
            find /www/server/panel/vhost/openlitespeed -type f -name "*.conf" -exec sed -i -E 's/(add\s+lsapi:[^\s]+\s+)php$/\1php,cme/g' {} +
        fi
        killall -9 lsphp > /dev/null 2>&1
        [ -f "/usr/local/lsws/bin/lswsctrl" ] && /usr/local/lsws/bin/lswsctrl restart > /dev/null 2>&1
        echo -e " ${C_GREEN}[OK] OpenLiteSpeed đã sẵn sàng chạy .cme${NC}"
    fi
}

install_php_core() {
    echo -e "\n${C_CYAN}[+] Đang quét cấu trúc PHP & Web Server...${NC}"
    if [ ! -d "/www/server/php" ]; then echo -e " ${C_RED}[ERROR] Không tìm thấy kiến trúc aaPanel (/www/server/php).${NC}"; return; fi

    for VER_DIR in /www/server/php/*; do
        VER=$(basename "$VER_DIR")
        if [[ "$VER" =~ ^[0-9]+$ ]] && [ "$VER" -ge 73 ]; then
            PHP_CONFIG="/www/server/php/${VER}/bin/php-config"
            if [ -f "$PHP_CONFIG" ]; then
                EXT_DIR=$($PHP_CONFIG --extension-dir)
                if [ -n "$EXT_DIR" ]; then
                    echo -e "\n ${C_YELLOW}[*] Đang xử lý PHP ${VER}...${NC}"
                    DOWNLOAD_URL="${CDN_BASE}/so/php${VER}/vinipoly.so"
                    HTTP_STATUS=$(curl -s -L -o "${EXT_DIR}/vinipoly.so.tmp" -w "%{http_code}" "$DOWNLOAD_URL")

                    if [ "$HTTP_STATUS" == "200" ]; then
                        mv "${EXT_DIR}/vinipoly.so.tmp" "${EXT_DIR}/vinipoly.so"; chmod 755 "${EXT_DIR}/vinipoly.so"

                        INI_FILE="/www/server/php/${VER}/etc/php.ini"
                        CLI_INI="/www/server/php/${VER}/etc/php-cli.ini"
                        [ -f "$INI_FILE" ] && sed -i '/vinipoly.so/d' "$INI_FILE" && echo "extension=${EXT_DIR}/vinipoly.so" >> "$INI_FILE"
                        [ -f "$CLI_INI" ] && sed -i '/vinipoly.so/d' "$CLI_INI" && echo "extension=${EXT_DIR}/vinipoly.so" >> "$CLI_INI"

                        FPM_CONF="/www/server/php/${VER}/etc/php-fpm.conf"
                        if [ -f "$FPM_CONF" ]; then
                            sed -i '/security.limit_extensions/d' "$FPM_CONF"; echo "security.limit_extensions = .php .php3 .php4 .php5 .php7 .cme" >> "$FPM_CONF"
                        fi

                        VER_DOT="${VER:0:1}.${VER:1:1}"
                        OLS_INI_DOT="/usr/local/lsws/lsphp${VER}/etc/php/${VER_DOT}/litespeed/php.ini"
                        OLS_INI_NO_DOT="/usr/local/lsws/lsphp${VER}/etc/php/${VER}/litespeed/php.ini"
                        if [ -f "$OLS_INI_DOT" ]; then sed -i '/vinipoly.so/d' "$OLS_INI_DOT" && echo "extension=${EXT_DIR}/vinipoly.so" >> "$OLS_INI_DOT"
                        elif [ -f "$OLS_INI_NO_DOT" ]; then sed -i '/vinipoly.so/d' "$OLS_INI_NO_DOT" && echo "extension=${EXT_DIR}/vinipoly.so" >> "$OLS_INI_NO_DOT"; fi

                        [ -f "/etc/init.d/php-fpm-${VER}" ] && /etc/init.d/php-fpm-${VER} restart > /dev/null 2>&1
                        echo -e " ${C_GREEN}[OK] Thành công: PHP ${VER} đã được gắn Giáp bảo mật!${NC}"
                    else
                        rm -f "${EXT_DIR}/vinipoly.so.tmp"
                        echo -e " ${C_RED}[ERROR] Thất bại: Không tìm thấy gói build cho PHP ${VER}.${NC}"
                    fi
                fi
            fi
        fi
    done
    reroute_webserver
}

# =================================================================
# CLI ARGUMENTS
# =================================================================
if [ "$1" == "--encoder" ]; then
    echo -e "\n${C_YELLOW}[i] Chế độ tải nhanh Encoder CLI...${NC}"
    curl -s -f -L "${CDN_BASE}/bin/vinipoly-encoder" -o "/usr/local/bin/vinipoly-encoder"; chmod +x "/usr/local/bin/vinipoly-encoder"
    echo -e " ${C_GREEN}[OK] Đã tải công cụ Encoder.${NC}\n"
    exit 0
fi

# =================================================================
# INITIAL SETUP WIZARD
# =================================================================
if [ ! -f "$BIN_PATH" ] || [ ! -f "$LICENSE_FILE" ]; then
    clear
    echo -e "${C_CYAN}========================================================${NC}"
    echo -e "${C_WHITE}    [ VINIPOLY DRM - ENTERPRISE INITIAL SETUP ]${NC}"
    echo -e "${C_CYAN}========================================================${NC}"

    read -p ">> Nhập Recovery License Key: " INPUT_KEY
    if [ -z "$INPUT_KEY" ]; then exit 1; fi

    read -p ">> Nhập API Key (Nhấn Enter để bỏ qua nếu chưa có): " INPUT_API

    mkdir -p /www/server/
    echo "$INPUT_KEY" > "$LICENSE_FILE"; chmod 644 "$LICENSE_FILE"

    if [ -n "$INPUT_API" ]; then echo "$INPUT_API" > "$API_KEY_FILE"; chmod 600 "$API_KEY_FILE"; fi

    cp "$0" "$BIN_PATH"; chmod +x "$BIN_PATH"
    install_php_core
    echo -e "\n${C_GREEN}[OK] CÀI ĐẶT HOÀN TẤT! Gõ lệnh: ${C_CYAN}vinipoly${C_GREEN} để mở Menu.${NC}\n"
    exit 0
fi

# =================================================================
# INTERACTIVE CLI DASHBOARD
# =================================================================
show_dashboard() {
    while true; do
        clear
        LATEST_VER=$(curl -s --max-time 3 "${CDN_BASE}/install/version.txt")
        UPDATE_ALERT=""
        if [ -n "$LATEST_VER" ] && [ "$LATEST_VER" != "$APP_VERSION" ]; then
            UPDATE_ALERT="${C_RED} [!] Có bản cập nhật mới: $LATEST_VER (Bấm phím 6 để Update) ${NC}"
        fi

        CURRENT_KEY=$(cat "$LICENSE_FILE" 2>/dev/null)
        API_KEY_DISP="${C_GRAY}Chưa cấu hình${NC}"
        if [ -f "$API_KEY_FILE" ]; then API_KEY_DISP="${C_GREEN}Đã lưu hợp lệ${NC}"; fi

        echo -e "${C_CYAN}========================================================${NC}"
        echo -e "${C_WHITE}    VINIPOLY ENTERPRISE CONSOLE  -  Bản $APP_VERSION${NC}"
        echo -e "${C_CYAN}========================================================${NC}"
        echo -e "${UPDATE_ALERT}"
        echo -e " [+] Recovery Key (Local): ${CURRENT_KEY:0:8}........${CURRENT_KEY: -4}"
        echo -e " [+] API Key (Cloud)     : ${API_KEY_DISP}\n"

        echo -e " ${C_WHITE}[1]${NC} Cài đặt lại Lõi PHP (Install Core)"
        echo -e " ${C_WHITE}[2]${NC} Quản lý Khóa (Recovery Key & API Key)"
        echo -e " ${C_WHITE}[3]${NC} Mã hóa Dự án (Smart Local Encoder)"
        echo -e " ${C_WHITE}[4]${NC} Kiểm tra trạng thái máy chủ (Services)"
        echo -e " ${C_WHITE}[5]${NC} Tra cứu thông tin API Key (Cloud Info)"
        echo -e " ${C_WHITE}[6]${NC} Cập nhật ViniPoly (Auto-Update)"
        echo -e " ${C_WHITE}[7]${NC} Định tuyến lại Web Server (Nginx / OLS / Apache)"
        echo -e " ${C_WHITE}[0]${NC} Thoát\n"

        read -p ">> Chọn chức năng: " OPTION

        case $OPTION in
            1) install_php_core; read -p "Bấm Enter để quay lại..." ;;
            2)
                echo -e "\n${C_YELLOW}--- QUẢN LÝ KHÓA ---${NC}"
                echo -e " [1] Đổi Recovery Key (Dùng để giải mã Local trong RAM)"
                echo -e " [2] Đổi API Key (Dùng để giao tiếp Cloud)"
                read -p ">> Chọn loại khóa cần cập nhật (1-2): " KEY_OPT

                if [ "$KEY_OPT" == "1" ]; then
                    read -p ">> Nhập Recovery Key mới: " NEW_KEY
                    if [ -n "$NEW_KEY" ]; then echo "$NEW_KEY" > "$LICENSE_FILE"; chmod 644 "$LICENSE_FILE"; chown www:www "$LICENSE_FILE" 2>/dev/null; echo -e "${C_GREEN}[OK] Đã cập nhật Recovery Key & Ép quyền 644 thành công!${NC}"; fi
                elif [ "$KEY_OPT" == "2" ]; then
                    read -p ">> Nhập API Key mới: " NEW_API
                    if [ -n "$NEW_API" ]; then echo "$NEW_API" > "$API_KEY_FILE"; chmod 600 "$API_KEY_FILE"; echo -e "${C_GREEN}[OK] Đã lưu API Key cục bộ thành công!${NC}"; fi
                fi
                read -p "Bấm Enter để quay lại..." ;;
            3)
                echo -e "\n${C_CYAN}--- CÔNG CỤ MÃ HÓA THÔNG MINH (SMART ENCODER) ---${NC}"

                if [ -f "$API_KEY_FILE" ]; then
                    API_KEY=$(cat "$API_KEY_FILE")
                else
                    read -p ">> Nhập API Key (Xác thực Cloud): " API_KEY
                    if [ -n "$API_KEY" ]; then echo "$API_KEY" > "$API_KEY_FILE"; chmod 600 "$API_KEY_FILE"; else echo -e "${C_RED}[ERROR] Bắt buộc nhập API Key.${NC}"; read -p "Bấm Enter..."; continue; fi
                fi

                if [ ! -f "/usr/local/bin/vinipoly-encoder" ]; then
                    echo -e "[i] Đang tải Core Encoder từ CDN..."
                    curl -s -f -L "${CDN_BASE}/bin/vinipoly-encoder" -o "/usr/local/bin/vinipoly-encoder"; chmod +x "/usr/local/bin/vinipoly-encoder"
                fi

                read -p ">> Nhập đường dẫn Thư mục hoặc File (.php): " RAW_PATH
                TARGET_PATH=$(echo "$RAW_PATH" | tr -d '\r' | tr -d "'" | tr -d '"')
                TARGET_PATH="${TARGET_PATH%/}"

                declare -a PHP_FILES_ARRAY
                if [ -d "$TARGET_PATH" ]; then
                    echo -e "${C_YELLOW}[*] Đang phân tích Thư mục và check Quota...${NC}"
                    while IFS= read -r -d '' file; do PHP_FILES_ARRAY+=("$file"); done < <(find "$TARGET_PATH" -type d \( -name "vendor" -o -name "node_modules" \) -prune -o -type f -name "*.php" -print0)
                    IS_DIR=1
                elif [ -f "$TARGET_PATH" ]; then
                    if [[ "$TARGET_PATH" != *.php ]]; then echo -e "${C_RED}[ERROR] File được chọn không phải là định dạng .php!${NC}"; read -p "Bấm Enter..."; continue; fi
                    echo -e "${C_YELLOW}[*] Đang phân tích File lẻ và check Quota...${NC}"
                    PHP_FILES_ARRAY+=("$TARGET_PATH")
                    IS_DIR=0
                else
                    echo -e "${C_RED}[ERROR] Đường dẫn không tồn tại: $TARGET_PATH${NC}"; read -p "Bấm Enter..."; continue
                fi

                if [ ${#PHP_FILES_ARRAY[@]} -eq 0 ]; then echo -e "${C_RED}[ERROR] Không tìm thấy file .php nào hợp lệ (hoặc chỉ toàn thư viện ngoài)!${NC}"; read -p "Bấm Enter..."; continue; fi

                CONFLICT_COUNT=0; declare -a FILES_TO_ENCODE
                for php_file in "${PHP_FILES_ARRAY[@]}"; do cme_file="${php_file%.php}.cme"; if [ -f "$cme_file" ]; then ((CONFLICT_COUNT++)); fi; done

                OVERWRITE_ALL="n"
                if [ $CONFLICT_COUNT -gt 0 ]; then
                    echo -e "${C_YELLOW}[!] Phát hiện $CONFLICT_COUNT file .php đã có bản .cme mã hóa từ trước.${NC}"
                    read -p ">> Bạn muốn mã hóa lại và GHI ĐÈ các file cme này không? [y/N]: " ask_overwrite
                    if [[ "$ask_overwrite" =~ ^[Yy]$ ]]; then OVERWRITE_ALL="y"; fi
                fi

                for php_file in "${PHP_FILES_ARRAY[@]}"; do
                    cme_file="${php_file%.php}.cme"
                    if [ -f "$cme_file" ]; then
                        if [ "$OVERWRITE_ALL" == "y" ]; then FILES_TO_ENCODE+=("$php_file"); fi
                    else
                        FILES_TO_ENCODE+=("$php_file")
                    fi
                done

                TOTAL_FILES=${#FILES_TO_ENCODE[@]}
                if [ $TOTAL_FILES -eq 0 ]; then echo -e "${C_GRAY}[i] Đã bỏ qua tất cả file.${NC}"; read -p "Bấm Enter..."; continue; fi

                JSON_RES=$(curl -s "${API_BASE}/info?api_key=${API_KEY}")
                if echo "$JSON_RES" | grep -q "error"; then echo -e "${C_RED}[ERROR] API Key bị lỗi hoặc Tường lửa chặn IP của VPS này!${NC}"; rm -f "$API_KEY_FILE"; read -p "Bấm Enter..."; continue; fi
                QUOTA=$(echo "$JSON_RES" | grep -o '"quota":[^,}]*' | cut -d':' -f2)

                if [ "$TOTAL_FILES" -gt "$QUOTA" ]; then echo -e "${C_RED}[ERROR] Hạn ngạch không đủ! Dự án này cần $TOTAL_FILES lượt, nhưng bạn chỉ còn $QUOTA lượt.${NC}"; read -p "Bấm Enter..."; continue; fi

                WORKSPACE="/tmp/vp_build_$(date +%s)"
                SRC_DIR="$WORKSPACE/src"; OUT_DIR="$WORKSPACE/out"
                mkdir -p "$SRC_DIR" "$OUT_DIR"

                echo -e "[*] Đang sao chép $TOTAL_FILES file hợp lệ vào không gian bảo mật..."
                for f in "${FILES_TO_ENCODE[@]}"; do
                    if [ "$IS_DIR" -eq 1 ]; then
                        rel_path="${f#$TARGET_PATH/}"
                        mkdir -p "$SRC_DIR/$(dirname "$rel_path")"
                        cp "$f" "$SRC_DIR/$rel_path"
                    else
                        cp "$f" "$SRC_DIR/"
                    fi
                done

                echo -e "${C_YELLOW}[*] Đang thực thi mã hóa...${NC}"
                vinipoly-encoder --input "$SRC_DIR" --output "$OUT_DIR" --api-key "$API_KEY" --user-passkey "$CURRENT_KEY"

                if [ $? -eq 0 ]; then
                    if [ "$IS_DIR" -eq 1 ]; then
                        cp -a "$OUT_DIR/"* "$TARGET_PATH/" 2>/dev/null
                        echo -e "\n${C_GREEN}[OK] File (.cme) đã lưu vào: ${C_CYAN}$TARGET_PATH${NC}"
                    else
                        cp -a "$OUT_DIR/"* "$(dirname "$TARGET_PATH")/" 2>/dev/null
                        echo -e "\n${C_GREEN}[OK] File (.cme) đã xuất tại: ${C_CYAN}$(dirname "$TARGET_PATH")${NC}"
                    fi

                    curl -s -X POST "${API_BASE}/deduct-quota" -H "Content-Type: application/json" -d "{\"api_key\":\"$API_KEY\", \"file_count\":$TOTAL_FILES}" > /dev/null
                    echo -e "${C_YELLOW}[i] Đã trừ $TOTAL_FILES lượt vào tài khoản Cloud SaaS.${NC}"

                    echo -e "\n${C_RED}⚠️ BƯỚC QUAN TRỌNG: BẢO VỆ MÃ NGUỒN${NC}"
                    read -p ">> Bạn có muốn XÓA TẬN GỐC $TOTAL_FILES file .php vừa được mã hóa không? [y/N]: " ask_del
                    if [[ "$ask_del" =~ ^[Yy]$ ]]; then
                        for f in "${FILES_TO_ENCODE[@]}"; do rm -f "$f"; done
                        echo -e "${C_GREEN}[OK] Đã dọn dẹp file nguồn an toàn.${NC}"
                    fi
                else
                    echo -e "${C_RED}[ERROR] Mã hóa thất bại. Quota chưa bị trừ.${NC}"
                fi
                rm -rf "$WORKSPACE"; read -p "Bấm Enter để quay lại..." ;;
            4) check_services; read -p "Bấm Enter để quay lại..." ;;
            5)
                echo -e "\n${C_CYAN}--- TRA CỨU THÔNG TIN API KEY ---${NC}"
                if [ -f "$API_KEY_FILE" ]; then API_KEY=$(cat "$API_KEY_FILE"); else read -p ">> Nhập API Key: " API_KEY; if [ -n "$API_KEY" ]; then echo "$API_KEY" > "$API_KEY_FILE"; chmod 600 "$API_KEY_FILE"; fi; fi

                echo -e "[*] Đang kết nối đến Cloud..."
                JSON_RES=$(curl -s "${API_BASE}/info?api_key=${API_KEY}")

                if echo "$JSON_RES" | grep -q "error"; then
                    echo -e "${C_RED}[ERROR] API Key không hợp lệ hoặc đã bị khóa.${NC}"; rm -f "$API_KEY_FILE"
                else
                    PLAN=$(echo "$JSON_RES" | grep -o '"plan":"[^"]*' | cut -d'"' -f4)
                    QUOTA=$(echo "$JSON_RES" | grep -o '"quota":[^,}]*' | cut -d':' -f2)
                    STATUS=$(echo "$JSON_RES" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
                    HOSTS=$(echo "$JSON_RES" | grep -o '"hosts":"[^"]*' | cut -d'"' -f4)
                    EXPIRE=$(echo "$JSON_RES" | grep -o '"expire":"[^"]*' | cut -d'"' -f4)

                    echo -e "\n${C_GREEN} [ THÔNG TIN TÀI KHOẢN CLOUD ]${NC}"
                    echo -e " [+] Gói dịch vụ : ${C_YELLOW}${PLAN^^}${NC}"
                    echo -e " [+] Hạn ngạch   : ${C_CYAN}${QUOTA} files${NC}"
                    echo -e " [+] Tường lửa   : ${C_WHITE}${HOSTS}${NC}"
                    echo -e " [+] Hết hạn     : ${C_WHITE}${EXPIRE}${NC}"
                    echo -e " [+] Trạng thái  : ${C_GREEN}${STATUS^^}${NC}"
                fi
                read -p "Bấm Enter để quay lại..." ;;
            6)
                echo -e "\n${C_CYAN}--- AUTO UPDATE ---${NC}"
                if [ -n "$LATEST_VER" ] && [ "$LATEST_VER" != "$APP_VERSION" ]; then
                    echo -e "[*] Đang tải phiên bản $LATEST_VER..."
                    curl -s -f -L "${CDN_BASE}/install/${LATEST_VER}/installer_vinipoly" -o "${BIN_PATH}_temp"
                    if [ -f "${BIN_PATH}_temp" ]; then
                        mv "${BIN_PATH}_temp" "$BIN_PATH"; chmod +x "$BIN_PATH"
                        echo -e "${C_GREEN}[OK] Nâng cấp thành công! Vui lòng gõ lại lệnh 'vinipoly'.${NC}"; exit 0
                    else
                        echo -e "${C_RED}[ERROR] Lỗi tải bản cập nhật.${NC}"
                    fi
                else
                    echo -e "${C_GREEN}[OK] Bạn đang dùng bản mới nhất ($APP_VERSION).${NC}"
                fi
                read -p "Bấm Enter để quay lại..." ;;
            7) reroute_webserver; read -p "Bấm Enter để quay lại..." ;;
            0) clear; exit 0 ;;
            *) echo -e "${C_RED}[ERROR] Lựa chọn không hợp lệ.${NC}"; sleep 1 ;;
        esac
    done
}
show_dashboard
