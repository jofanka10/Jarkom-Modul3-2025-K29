#Node: Galadriel, Celeborn, Oropher

nano /root/setup_php_worker_13.sh

#!/bin/bash
echo "=== Soal 13: Setup PHP Worker Basic ==="

apt update && apt install -y nginx php8.4-fpm

mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Buat index.php sederhana
cat > /var/www/html/index.php << 'EOF'
<?php
echo "Halo dari: " . gethostname();
?>
EOF

# Tentukan port
HOSTNAME=$(hostname)
case $HOSTNAME in
    "Galadriel") PORT=8004 ;;
    "Celeborn") PORT=8005 ;;
    "Oropher") PORT=8006 ;;
    *) PORT=8000 ;;
esac

# Config nginx basic
cat > /etc/nginx/sites-available/php-worker << EOF
server {
    listen $PORT;
    server_name _;
    root /var/www/html;
    index index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
EOF

ln -sf /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

php-fpm8.4 -D
nginx

echo "=== Soal 13 selesai: $HOSTNAME di port $PORT ==="