no 14.

#!/bin/bash
echo "=== SOAL 14: BASIC AUTH GALADRIEL ==="

# Install apache2-utils untuk htpasswd
apt update && apt install -y apache2-utils

# Buat password file (user: noldor, pass: silvan)
echo 'noldor:$apr1$4d6L8WjS$uZh/.Qz9jJn7H7dJ8HvDk.' > /etc/nginx/.htpasswd

# Update config nginx dengan auth
cat > /etc/nginx/sites-available/php-worker << 'EOF'
# Default server block untuk menangani request tanpa domain
server {
    listen 8004 default_server;
    server_name _;
    return 444;
}

# Server block untuk domain galadriel.k29.com
server {
    listen 8004;
    server_name galadriel.k29.com;
    root /var/www/html;
    index index.php index.html index.htm;

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

# Restart Nginx
nginx -s stop
nginx

echo "=== BASIC AUTH GALADRIEL SELESAI ==="
echo "Test: curl -u noldor:silvan http://galadriel.k29.com:8004"






#!/bin/bash
echo "=== SOAL 14: BASIC AUTH CELEBORN ==="

apt install -y apache2-utils

echo 'noldor:$apr1$4d6L8WjS$uZh/.Qz9jJn7H7dJ8HvDk.' > /etc/nginx/.htpasswd

cat > /etc/nginx/sites-available/php-worker << 'EOF'
server {
    listen 8005 default_server;
    server_name _;
    return 444;
}

server {
    listen 8005;
    server_name celeborn.k29.com;
    root /var/www/html;
    index index.php index.html index.htm;

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

nginx -s stop
nginx

echo "=== BASIC AUTH CELEBORN SELESAI ==="




#!/bin/bash
echo "=== SOAL 14: BASIC AUTH OROPHER ==="

apt install -y apache2-utils

echo 'noldor:$apr1$4d6L8WjS$uZh/.Qz9jJn7H7dJ8HvDk.' > /etc/nginx/.htpasswd

cat > /etc/nginx/sites-available/php-worker << 'EOF'
server {
    listen 8006 default_server;
    server_name _;
    return 444;
}

server {
    listen 8006;
    server_name oropher.k29.com;
    root /var/www/html;
    index index.php index.html index.htm;

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

nginx -s stop
nginx

echo "=== BASIC AUTH OROPHER SELESAI ==="







#test dari client
curl http://galadriel.k29.com:8004 #gagal
curl -u noldor:silvan http://galadriel.k29.com:8004
curl -u noldor:silvan http://celeborn.k29.com:8005
curl -u noldor:silvan http://oropher.k29.com:8006

#kalau tetep ga bisa 

apt install -y apache2-utils

htpasswd -bc /etc/nginx/.htpasswd noldor silvan

chown www-data:www-data /etc/nginx/.htpasswd
chmod 644 /etc/nginx/.htpasswd

nginx -s stop
nginx


curl -u noldor:silvan http://galadriel.k29.com:8004
