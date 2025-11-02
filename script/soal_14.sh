13 dan 14

### 10.78.2.5, 10.78.2.6, 10.78.2.7

apt update && apt install apache2-utils -y
htpasswd -cb /etc/nginx/.htpasswd noldor silvan
nano /etc/nginx/sites-available/default

```
# BLOK 1: Menangkap akses IP (dan menolaknya) 
server {
    listen 8004 default_server; # Port Galadriel 
    listen [::]:8004 default_server;
    server_name _; 
    return 404; 
}

# BLOK 2: Menerima akses Domain (dengan password)
server {
    listen 8004;
    listen [::]:8004;
    server_name galadriel.K29.com; # Domain Galadriel 

    root /var/www/html;
    index index.php index.html index.htm;

    # Soal 120: Basic HTTP Authentication
    auth_basic "Taman Terlarang";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
```
Restart nginx
```
nginx -t  # Pastikan "syntax is ok"
service nginx restart
```

### Client (Amandil)
curl -I http://10.78.2.5:8004
curl -I http://galadriel.K29.com:8004
curl --user "noldor:silvan" http://galadriel.K29.com:8004
