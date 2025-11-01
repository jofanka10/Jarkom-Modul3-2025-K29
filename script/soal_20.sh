#NGINX CACHING

#Node: Pharazon


nano /root/setup_caching_20.sh

#!/bin/bash
echo "=== Soal 20: Setup Nginx Caching ==="

# Edit config dengan caching
cat > /etc/nginx/sites-available/php-lb << 'EOF'
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=10g inactive=60m;

upstream kesatria_lorien {
    server 10.78.2.5:8004;
    server 10.78.2.6:8005;
    server 10.78.2.7:8006;
}

server {
    listen 80;
    server_name pharazon.k29.com;

    location / {
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
        proxy_pass http://kesatria_lorien;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Authorization $http_authorization;
        proxy_pass_header Authorization;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
EOF

# Buat cache directory
mkdir -p /var/cache/nginx
chown -R www-data:www-data /var/cache/nginx

# Restart nginx
nginx -s stop
nginx

echo "=== Soal 20 selesai: Nginx caching activated ==="

