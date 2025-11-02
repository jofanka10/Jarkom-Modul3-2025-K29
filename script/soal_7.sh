apt update

## /root/install_laravel.sh

#!/bin/bash

# Update
apt update
apt upgrade -y

# Install nginx, php, dan dependencies
apt install -y nginx curl wget git

# Tambah repository PHP 8.4
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.4 php8.4-fpm php8.4-mysql php8.4-xml php8.4-curl php8.4-zip php8.4-mbstring php8.4-gd

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Start services tanpa systemctl
service nginx start
service php8.4-fpm start
```


### ke 2

```
#!/bin/bash
echo "=== Fix Composer untuk PHP 8.4 ==="

cd /var/www/laravel-app

# Hapus vendor dan composer.lock yang lama
rm -rf vendor
rm -f composer.lock

# Update composer.json untuk kompatibel dengan PHP 8.4
cat > composer.json << 'EOF'
{
    "name": "laravel/laravel",
    "type": "project",
    "description": "Laravel Simple REST API",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "require": {
        "php": "^8.1",
        "guzzlehttp/guzzle": "^7.2",
        "laravel/framework": "^10.10",
        "laravel/sanctum": "^3.2",
        "laravel/tinker": "^2.8"
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "laravel/pint": "^1.0",
        "laravel/sail": "^1.18",
        "mockery/mockery": "^1.4.4",
        "nunomaduro/collision": "^7.0",
        "phpunit/phpunit": "^10.1",
        "spatie/laravel-ignition": "^2.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# Install ulang dependencies
composer install --no-dev --optimize-autoloader

# Setup permissions dan .env
chown -R www-data:www-data /var/www/laravel-app
chmod -R 775 storage bootstrap/cache

cp .env.example .env
php artisan key:generate

echo "=== Composer fixed untuk PHP 8.4 ==="

chmod +x /root/fix_composer.sh
/root/fix_composer.sh
```


```
## /root/setup_laravel.sh

#!/bin/bash

# Hapus default nginx
rm -rf /var/www/html/*

# Clone project
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git
mv laravel-simple-rest-api laravel-app
cd laravel-app

# Install dependencies
composer install --no-dev

# Set permissions
chown -R www-data:www-data /var/www/laravel-app
chmod -R 775 storage bootstrap/cache

# Setup .env
cp .env.example .env
php artisan key:generate
```






```
## /etc/nginx/sites-available/laravel

server {
    listen 80;
    server_name _;
    root /var/www/laravel-app/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```





## /root/configure_nginx.sh
```
#!/bin/bash

# Backup default config
cp /etc/nginx/sites-available/laravel /etc/nginx/sites-available/laravel.backup

# Copy config kita
cat > /etc/nginx/sites-available/laravel << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/laravel-app/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test dan restart nginx
nginx -t
service nginx restart
service php8.4-fpm restart
```



```
chmod +x /root/install_laravel.sh
chmod +x /root/setup_laravel.sh
chmod +x /root/configure_nginx.sh
```
```
/root/install_laravel.sh
/root/setup_laravel.sh
/root/configure_nginx.sh
```


Uji coba
```
apt update
apt install lynx -y


lynx http://10.78.1.2
lynx http://10.78.1.3
lynx http://10.78.1.4
```
