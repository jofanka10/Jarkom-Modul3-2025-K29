#Node: Elros (10.78.1.7)

nano /root/setup_lb_laravel.sh

#!/bin/bash
echo "=== Setup Load Balancer Laravel di Elros ==="

# Install nginx
apt update && apt install -y nginx

# Buat config load balancer
cat > /etc/nginx/sites-available/laravel-lb << 'EOF'
upstream kesatria_numenor {
    server 10.78.1.2:8001;
    server 10.78.1.3:8002;
    server 10.78.1.4:8003;
}

server {
    listen 80;
    server_name elros.k29.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/laravel-lb /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test dan start nginx
nginx -t
nginx

echo "=== Load Balancer Laravel selesai ==="