### Palantir

apt update apt install mariadb-server -y

nano /etc/mysql/mariadb.conf.d/50-server.cnf

bind-address = 0.0.0.0

service mariadb start

mysql -u root

CREATE DATABASE ikan; CREATE USER 'laravel2'@'%' IDENTIFIED BY 'passwordBaru123'; GRANT ALL PRIVILEGES ON ikan.* TO 'laravel2'@'%'; FLUSH PRIVILEGES; EXIT;

netstat -tlnp | grep 3306

### Node Worker

cd /var/www/laravel-app

nano .env

DB_CONNECTION=mysql DB_HOST=10.78.4.3 # IP Palantir DB_PORT=3306 DB_DATABASE=ikan # Database Anda DB_USERNAME=laravel2 # User Anda DB_PASSWORD=passwordBaru123 # Password Anda

php artisan migrate --seed

nano /etc/nginx/sites-available/laravel

```
# BLOK 1: Menangkap akses IP (dan menolaknya)
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
    server_name elendil.K29.com; # Domain Elendil

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
nginx -t  # Pastikan "syntax is ok"
service nginx restart


### Uji Cobva Client

echo "nameserver 10.78.3.3" > /etc/resolv.conf

curl -I http://10.78.1.2:8001

curl http://elendil.K29.com:8001/api/airing
