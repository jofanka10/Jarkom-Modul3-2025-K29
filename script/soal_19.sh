#RATE LIMITING

#Node: Elros & Pharazon


nano /root/setup_rate_limit_19.sh

#!/bin/bash
echo "=== Soal 19: Setup Rate Limiting ==="

# Backup config
cp /etc/nginx/sites-available/laravel-lb /etc/nginx/sites-available/laravel-lb.backup

# Edit config dengan rate limiting
cat > /etc/nginx/sites-available/laravel-lb << 'EOF'
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;

upstream kesatria_numenor {
    server 10.78.1.2:8001;
    server 10.78.1.3:8002;
    server 10.78.1.4:8003;
}

server {
    listen 80;
    server_name elros.k29.com;

    location / {
        limit_req zone=one burst=20;
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Restart nginx
nginx -s stop
nginx

echo "=== Soal 19 selesai: Rate limiting 10 req/s ==="