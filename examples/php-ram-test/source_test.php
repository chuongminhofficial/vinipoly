<?php
// ==========================================
// VINIPOLY DRM - COMPREHENSIVE TEST SUITE
// ==========================================

// 1. Kiểm tra biến, mảng và logic PHP
$app_name = "ViniPoly Enterprise Core";
$version = "2.5.0-Production";
$server_time = date('Y-m-d H:i:s');
$developer = "Phạm Minh Chương";

$system_features = [
    ["name" => "RAM Execution", "status" => "Active", "desc" => "Không ghi dữ liệu ra ổ cứng đĩa cứng"],
    ["name" => "AES-256-GCM", "status" => "Secured", "desc" => "Mã hóa cấp độ quân sự chống dịch ngược"],
    ["name" => "Frontend Cloaking", "status" => "Protected", "desc" => "Ẩn source code, chặn F12 và chuột phải"],
    ["name" => "SEO Optimization", "status" => "Optimized", "desc" => "Thân thiện tuyệt đối với GoogleBot / Crawlers"]
];

$secure_token = bin2hex(random_bytes(16));
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $app_name; ?> - Test Suite</title>
    <style>
        :root {
            --bg-color: #0f172a;
            --card-bg: #1e293b;
            --text-main: #f8fafc;
            --accent: #38bdf8;
            --success: #10b981;
            --border: #334155;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            margin: 0;
            padding: 40px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.4);
        }
        h1 { color: var(--accent); margin-top: 0; display: flex; align-items: center; justify-content: space-between; }
        .badge { background: var(--success); color: white; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: bold; }
        .feature-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .feature-table th, .feature-table td { border: 1px solid var(--border); padding: 12px; text-align: left; }
        .feature-table th { background: #0f172a; color: var(--accent); }
        .footer { margin-top: 30px; font-size: 13px; color: #94a3b8; border-top: 1px solid var(--border); padding-top: 15px; display: flex; justify-content: space-between; }
        .token-box { background: #0f172a; padding: 10px; border-radius: 6px; font-family: monospace; color: #a855f7; margin-top: 15px; }
    </style>
</head>
<body>

    <div class="container">
        <h1>
            <span>🛡️ <?php echo $app_name; ?></span>
            <span class="badge">v<?php echo $version; ?></span>
        </h1>
        
        <p>Xin chào <strong><?php echo htmlspecialchars($developer); ?></strong>! Tệp này đang được giải mã và thực thi hoàn toàn trong RAM nhờ Zend Extension của ViniPoly.</p>

        <h3>📊 Bảng trạng thái tính năng DRM:</h3>
        <table class="feature-table">
            <thead>
                <tr>
                    <th>Tính năng cốt lõi</th>
                    <th>Trạng thái</th>
                    <th>Mô tả kỹ thuật</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($system_features as $feat): ?>
                <tr>
                    <td><strong><?php echo $feat['name']; ?></strong></td>
                    <td><span style="color: var(--success);">● <?php echo $feat['status']; ?></span></td>
                    <td><?php echo $feat['desc']; ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <div class="token-box">
            🔑 Dynamic Secure Token (RAM Generated): <strong><?php echo $secure_token; ?></strong>
        </div>

        <div class="footer">
            <span>Server Time: <?php echo $server_time; ?></span>
            <span>Protected by Chương Minh® Studio</span>
        </div>
    </div>

    <script>
        console.log("⚡ ViniPoly Frontend Cloaking: Hoạt động hoàn hảo!");
    </script>
</body>
</html>