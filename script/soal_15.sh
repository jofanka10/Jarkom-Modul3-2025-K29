15

### 10.78.2.5, 10.78.2.6, 10.78.2.7

nano /etc/nginx/sites-available/default
```
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;

    # TAMBAHKAN BARIS INI (Soal 121)
    fastcgi_param X-Real-IP $remote_addr;
}

```
Restart nginx
```
nginx -t
service nginx restart
```
nano /var/www/html/index.php
```
<?php
    // Ambil IP asli dari parameter Nginx
    // Gunakan '??' untuk memberi nilai default jika header tidak ada
    $ip_asli = $_SERVER['X-Real-IP'] ?? 'Tidak Dikenali';

    echo 'Halo, ini adalah ' . gethostname() . '. IP Asli Anda: ' . $ip_asli;
?>
```

### Uji Coba di Client (Amandil)
Pstikan
```
echo "nameserver 10.78.3.3" > /etc/resolv.conf
curl --user "noldor:silvan" http://galadriel.K29.com:8004
```


