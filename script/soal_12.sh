#di Node: Galadriel (10.78.2.5), Celeborn (10.78.2.6), Oropher (10.78.2.7)

nano /root/setup_php_worker.sh

#!/bin/bash
echo "=== Setup PHP Worker ==="

# Install paket
apt update && apt install -y nginx php8.4-fpm

# Buat web directory
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Buat index.php dengan hostname
cat > /var/www/html/index.php << 'EOF'
<?php
echo "Halo dari: " . gethostname() . "<br>";
echo "IP Pengunjung: " . ($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']);
?>
EOF

# Tentukan port berdasarkan hostname
HOSTNAME=$(hostname)
case $HOSTNAME in
    "Galadriel") PORT=8004 ;;
    "Celeborn") PORT=8005 ;;
    "Oropher") PORT=8006 ;;
    *) PORT=8000 ;;
esac

# Buat config nginx
cat > /etc/nginx/sites-available/php-worker << EOF
server {
    listen $PORT;
    server_name \$hostname.k29.com;
    root /var/www/html;
    index index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start services
php-fpm8.4 -D
nginx

echo "=== PHP Worker $HOSTNAME selesai di port $PORT ==="