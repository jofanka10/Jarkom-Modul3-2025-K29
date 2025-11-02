16

### Pharazon

# (Ganti DNS ke Minastir '10.78.5.2' jika perlu install)
apt update
apt install nginx -y

nano /etc/nginx/sites-available/load_balancer_peri

```
# Soal 125: Buat upstream Kesatria_Lorien
upstream Kesatria_Lorien {
    
    # Masukkan alamat IP:PORT dari ketiga worker PHP
    server 10.78.2.5:8004;  # Galadriel
    server 10.78.2.6:8005;  # Celeborn
    server 10.78.2.7:8006;  # Oropher
}

server {
    listen 80;
    listen [::]:80;

    # Soal 126: Atur agar permintaan datang ke domain pharazon
    server_name pharazon.K29.com;

    location / {
        # Teruskan permintaan ke grup upstream
        proxy_pass http://Kesatria_Lorien;

        # --- PENTING (Soal 126) ---
        # Baris ini memberitahu Nginx untuk meneruskan
        # header "Authorization" (info login) ke worker
        proxy_pass_request_headers on;
        proxy_set_header Authorization $http_authorization;

        # Header tambahan (good practice)
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```
# 1. Aktifkan file baru kita
ln -s /etc/nginx/sites-available/load_balancer_peri /etc/nginx/sites-enabled/

# 2. Hapus link default (jika ada)
rm -f /etc/nginx/sites-enabled/default

# 3. Tes konfigurasi
nginx -t

# 4. Jika "syntax is ok", restart Nginx
service nginx restart
```

### Uji Coba di Client
```
echo "nameserver 10.78.3.3" > /etc/resolv.conf
curl --user "noldor:silvan" http://pharazon.K29.com
```

