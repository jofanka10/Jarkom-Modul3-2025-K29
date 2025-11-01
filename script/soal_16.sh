#LOAD BALANCER PHP (Pharazon)

#Node: Pharazon (10.78.2.4)

nano /root/setup_lb_php_16.sh

#!/bin/bash
echo "=== Soal 16: Load Balancer PHP ==="

apt update && apt install -y nginx

cat > /etc/nginx/sites-available/php-lb << 'EOF'
upstream kesatria_lorien {
    server 10.78.2.5:8004;
    server 10.78.2.6:8005;
    server 10.78.2.7:8006;
}

server {
    listen 80;
    server_name pharazon.k29.com;

    location / {
        proxy_pass http://kesatria_lorien;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Authorization $http_authorization;
        proxy_pass_header Authorization;
    }
}
EOF

ln -sf /etc/nginx/sites-available/php-lb /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
nginx

echo "=== Soal 16 selesai: Load Balancer PHP ==="