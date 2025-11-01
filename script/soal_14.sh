#TAMBAH BASIC AUTH

#Node: Galadriel, Celeborn, Oropher

nano /root/setup_php_auth_14.sh

#!/bin/bash
echo "=== Soal 14: Tambah Basic Auth ==="

apt install -y apache2-utils

# Buat password file (user: noldor, pass: silvan)
echo 'noldor:$apr1$4d6L8WjS$uZh/.Qz9jJn7H7dJ8HvDk.' > /etc/nginx/.htpasswd

# Update config nginx dengan auth
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
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOF

# Restart nginx
nginx -s stop
nginx

echo "=== Soal 14 selesai: Basic Auth ditambahkan ==="