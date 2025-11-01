#TAMBAH X-REAL-IP HEADER

#Node: Galadriel, Celeborn, Oropher

nano /root/setup_php_realip_15.sh

#!/bin/bash
echo "=== Soal 15: Tambah X-Real-IP Header ==="

# Update index.php untuk tampilkan IP
cat > /var/www/html/index.php << 'EOF'
<?php
echo "<h1>Halo dari: " . gethostname() . "</h1>";
echo "<p>IP Pengunjung: " . ($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']) . "</p>";
?>
EOF

# Update config nginx dengan X-Real-IP
cat > /etc/nginx/sites-available/php-worker << 'EOF'
server {
    listen 8004;
    server_name _;
    root /var/www/html;
    index index.php;

    location / {
        try_files $uri $uri/ =404;
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param HTTP_X_REAL_IP $remote_addr;
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

# Restart nginx
nginx -s stop
nginx

echo "=== Soal 15 selesai: X-Real-IP Header ditambahkan ==="