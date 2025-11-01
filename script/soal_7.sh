#INSTALASI LARAVEL

#Node: Elendil, Isildur, Anarion

nano /root/soal7_install_laravel.sh

#!/bin/bash
echo "=== SOAL 7: INSTALASI LARAVEL ==="

apt update && apt upgrade -y
apt install -y nginx curl wget git software-properties-common

# Install PHP 8.4
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.4 php8.4-fpm php8.4-mysql php8.4-xml php8.4-curl php8.4-zip php8.4-mbstring php8.4-gd

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Clone Laravel
rm -rf /var/www/html/*
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git
mv laravel-simple-rest-api laravel-app
cd laravel-app

composer install --no-dev

chown -R www-data:www-data /var/www/laravel-app
chmod -R 775 storage bootstrap/cache

cp .env.example .env
php artisan key:generate

# Start services
php-fpm8.4 -D
nginx

echo "=== SOAL 7 SELESAI ==="