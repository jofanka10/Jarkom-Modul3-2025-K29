#KONFIGURASI DATABASE & NGINX

#Node: Elendil, Isildur, Anarion

nano /root/soal8_config_database.sh

#!/bin/bash
echo "=== SOAL 8: KONFIGURASI DATABASE & NGINX ==="

# Deteksi port berdasarkan hostname
HOSTNAME=$(hostname)
case $HOSTNAME in
    "Elendil") PORT=8001 ;;
    "Isildur") PORT=8002 ;;
    "Anarion") PORT=8003 ;;
    *) PORT=8000 ;;
esac

# Update .env untuk database Palantir
cat > /var/www/laravel-app/.env << 'EOF'
APP_NAME=Laravel
APP_ENV=production
APP_KEY=base64:$(grep APP_KEY /var/www/laravel-app/.env | cut -d= -f2 | sed 's/ //g')
APP_DEBUG=false
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=10.78.4.3
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=password123

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF

# Buat config Nginx dengan port berbeda
cat > /etc/nginx/sites-available/laravel << EOF
server {
    listen $PORT;
    server_name _;
    root /var/www/laravel-app/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}

# Blok akses via IP
server {
    listen $PORT;
    server_name _;
    return 444;
}
EOF

# Enable site dan restart
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -s stop
nginx

echo "=== SOAL 8 SELESAI: $HOSTNAME di port $PORT ==="