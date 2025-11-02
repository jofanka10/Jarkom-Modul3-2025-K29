### Elros

apt update
apt install nginx -y

nano /etc/nginx/sites-available/load_balancer

```
# Soal 106: Buat upstream bernama kesatria_numenor
upstream kesatria_numenor {
    
    # Soal 107: Algoritma Round Robin (ini adalah default Nginx)
    
    # Masukkan alamat IP:PORT dari ketiga worker Anda
    server 10.78.1.2:8001;  # Elendil
    server 10.78.1.3:8002;  # Isildur
    server 10.78.1.4:8003;  # Anarion
}

server {
    listen 80;
    listen [::]:80;

    # Soal 107: Atur agar permintaan datang ke domain elros
    server_name elros.K29.com;

    location / {
        # Teruskan semua permintaan ke grup upstream di atas
        proxy_pass http://kesatria_numenor;

        # Header tambahan ini adalah praktik yang baik
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

1. Aktifkan file baru kita
ln -s /etc/nginx/sites-available/load_balancer /etc/nginx/sites-enabled/

2. Hapus link default (jika ada)
rm -f /etc/nginx/sites-enabled/default

3. Tes konfigurasi
nginx -t

4. Jika "syntax is ok", restart Nginx
service nginx restart


### Amandil

echo "nameserver 10.78.3.3" > /etc/resolv.conf

Tes halaman utama
curl http://elros.K29.com
Tes API
curl http://elros.K29.com/api/airing


Jika tidak bisa, bisa tambahkan server_name ke Worker (Elendil dkk)

### Config Worker (Elendil)
`nano /etc/nginx/sites-available/laravel`
```
server {
    listen 8001 default_server; # Port Elendil
    listen [::]:8001 default_server;
    server_name _;
    return 404; # Tolak akses IP [cite: 102]
}

# BLOK 2: Menerima akses Domain
server {
    listen 8001;
    listen [::]:8001;
    server_name elendil.K29.com elros.K29.com; # Domain Elendil

    root /var/www/laravel-app/public; # Folder proyek Anda
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
```
