12

### 10.78.2.5, 10.78.2.6, 10.78.2.7

apt update && apt install nginx php8.4-fpm -y
(jika tidak bisa, cek ping google.com dan ubah nameservernya)


echo "<?php echo 'Halo, ini adalah ' . gethostname(); ?>" > /var/www/html/index.php

nano /etc/nginx/sites-available/default
```
# Ubah baris ini:
index index.html index.htm index.nginx-debian.html;
# Menjadi:
index index.php index.html index.htm;
```
```
location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    # Pastikan ini menunjuk ke socket PHP 8.4
    fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
}
```
### Uji Coba di Amandil
```
nginx -t  # Pastikan "syntax is ok"
service nginx restart
service php8.4-fpm restart
```
```
# Tes Galadriel (10.78.2.5)
curl http://10.78.2.5

# Tes Celeborn (10.78.2.6)
curl http://10.78.2.6

# Tes Oropher (10.78.2.7)
curl http://10.78.2.7
```
