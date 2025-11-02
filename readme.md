# Laporan Resume Jarkom Modul 3

Anggota
| Nama | NRP |
|------|---------|
| Christiano Ronaldo Silalahi | 5027241025 |
| Jofanka Al-Kautsar Pangestu Abady | 5027241107 |

## No. 1
Agar semua Node kecuali Durin dapat terhubung ke Internet, kita perlu konfigurasi semua node. Untuk konfigurasinya seperti ini

### Durin (Router)
```
auto eth0
iface eth0 inet dhcp
        up echo nameserver 192.168.122.1 > /etc/resolv.conf

auto eth1
iface eth1 inet static
	address 10.78.1.1
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 10.78.2.1
	netmask 255.255.255.0

auto eth3
iface eth3 inet static
	address 10.78.3.1
	netmask 255.255.255.0

auto eth4
iface eth4 inet static
	address 10.78.4.1
	netmask 255.255.255.0

auto eth5
iface eth5 inet static
	address 10.78.5.1
	netmask 255.255.255.0

sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.1.0/16
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.2.0/16
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.3.0/16
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.4.0/16
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.5.0/16
iptables -A OUTPUT -o eth0 -j DROP
```


"...dan pastikan setiap node (selain Durin sang penghubung antar dunia) dapat sementara berkomunikasi dengan Valinor/Internet (nameserver 192.168.122.1) untuk menerima instruksi awal."
Berarti pada sang Penghubung Antar Dunia tidak boleh terhubung ke internet. Pada konfigurasi tersebut, kode ini ditambahkan ke Durin.
```
iptables -A OUTPUT -o eth0 -j DROP
```

### Node Lain
Lalu, pada node lainnya, konfigurasinya seperti ini (static).

```
auto eth0
iface eth0 inet static
	address {ip_address}
	netmask 255.255.255.0
	gateway {gateway}
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```

Untuk dynamic seperti ini
```
auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```

Tentunya IP tersebut menyesuaikan setiap node. Untuk daftar setiap nodenya seperti ini.
| Node  | {gateway} | {ip_address} |
| --- | --- | --- |
| Elendil | 10.78.1.1 | 10.78.1.2 |
| Isdilur | 10.78.1.1 | 10.78.1.3 |
| Anarion | 10.78.1.1 | 10.78.1.4 |
| Miriel | 10.78.1.1 | 10.78.1.5 |
| Amandil | 10.78.1.1 | dynamic |
| Elros | 10.78.1.1 |10.78.1.7|
| Gilgalad | 10.78.2.1 | dynamic |
| Celebrimor | 10.78.2.1 | 10.78.2.3 |
| Pharazom | 10.78.2.1 | 10.78.2.4 |
| Galadriel | 10.78.2.1 | 10.78.2.5 |
| Celeborn | 10.78.2.1 | 10.78.2.6 |
| Oropher | 10.78.2.1 | 10.78.2.7 |
| Khamul | 10.78.3.1 | 10.78.3.2 |
| Erendis | 10.78.3.1 | 10.78.3.3 |
| Amdir | 10.78.3.1 | 10.78.3.4 |
| Aldarion | 10.78.4.1 | 10.78.4.2 |
| Palantir | 10.78.4.1 | 10.78.4.3 |
| Narvi | 10.78.4.1 | 10.78.4.4 |
| Minastir | 10.78.5.1 | 10.78.5.2 |

Jika berhasil, maka akan muncul seperti ini.

### Pada Durin

<img width="1104" height="447" alt="Screenshot 2025-10-29 at 00 23 00" src="https://github.com/user-attachments/assets/27011dd0-2067-45b2-8982-85f27e3cab8e" />

### Pada Node Lainnya

<img width="1313" height="821" alt="Screenshot 2025-10-29 at 00 24 30" src="https://github.com/user-attachments/assets/dd3bbd7f-f984-47b5-a03a-572ac2a09013" />


## No. 2
Pada soal ini, kita akan setting pada Durin dan Aldarion agar mereka dapat terkoneksi ke client yang memiliki dynamic IP.
### Setting Durin
Pada Durin, mula-mula kita akan install DHCP Relay. Untuk kodenya seperti ini.

```
apt-get update
apt-get install isc-dhcp-relay -y
```

Lalu, kita akan konfigurasi pada `/etc/default/isc-dhcp-relay`. Untuk konfigurasinya seperti ini
```
SERVERS="10.78.4.2"

INTERFACES="eth1 eth2 eth3"

OPTIONS="-a -i eth4"
```

### Setting Aldarion
Mula-mula, kita install DHCP Server. Untuk kodenya seperti ini.
```
apt-get update
apt-get install isc-dhcp-server -y
```
Lalu, kita akan melakukan config pada `/etc/dhcp/dhcpd.conf`. Untuk confignya seperti ini.
```
option domain-name "numenor.lab";
option domain-name-servers 10.78.3.2, 10.78.4.2; # Pindahkan ke global untuk keseragaman, atau biarkan di subnet
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Subnet for Human Family (10.78.1.0/24)
subnet 10.78.1.0 netmask 255.255.255.0 {
    range 10.78.1.6 10.78.1.34;
    range 10.78.1.68 10.78.1.94;

    # Klien akan menggunakan Durin (10.78.1.1) sebagai gateway
    option routers 10.78.1.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.1.255;
    option domain-name-servers 10.78.3.2, 10.78.4.2;

    default-lease-time 1800;
    max-lease-time 3600;
}

# Subnet for Elf Family (10.78.2.0/24)
subnet 10.78.2.0 netmask 255.255.255.0 {
    range 10.78.2.35 10.78.2.67;
    range 10.78.2.96 10.78.2.121;

    # Klien akan menggunakan Durin (10.78.2.1) sebagai gateway
    option routers 10.78.2.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.2.255;
    option domain-name-servers 10.78.3.2, 10.78.4.2;

    default-lease-time 600;
    max-lease-time 3600;
}

# Subnet untuk jaringan Aldarion (server DHCP)
subnet 10.78.4.0 netmask 255.255.255.0 {
    range 10.78.4.10 10.78.4.20;
    option routers 10.78.4.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.4.255;
    option domain-name-servers 10.78.3.2, 10.78.4.2;

    # Tidak perlu lease-time karena IP statis/server
}

# Fixed address for Khamul (di subnet 10.78.3.0/24)
host khamul {
    hardware ethernet 02:42:ab:01:c2:00;
    fixed-address 10.78.3.95;

    # Khamul juga harus tahu gateway dan DNS
    option routers 10.78.3.1;
    option domain-name-servers 10.78.3.2, 10.78.4.2;
}
```

Note: Cara untuk mendapatkan ethernet di Khamul adalah dengan melakukan `ip a show eth0` pada Khamul lalu copy kode seperti `02:42:ab:01:c2:00` ke `/etc/dhcp/dhcpd.conf` di Aldarion.

Lalu, kita akan config `/etc/default/isc-dhcp-server` menjadi seperti ini.

```
INTERFACESv4="eth0"
INTERFACESv6=""
```

## Pada Client (Amandil/Gilgalad)
Selanjutnya, pada client lakukan restart node. Lalu, cek dengan ini.
```
ip a show eth0
```

## Kembali ke Aldarion
Start DHCP pada Aldarion.
```
service isc-dhcp-server start
```
Jika ada IP maka prosesnya sudah berhasil. Selain itu, pada **Aldarion** kita bisa lakukan pengecekan dengan 
```
cat /var/lib/dhcp/dhcpd.leases
```

Jika berhasil akan muncul seperti ini.

![WhatsApp Image 2025-10-30 at 13 58 47](https://github.com/user-attachments/assets/e45a2369-4a53-45d7-a1c3-191b416a1a01)


## No. 3
Sekarang, kita akan jadikan Minastir agar ia dapat mengatur node lain (selain Durin) dapat berkirim pesan ke luar Arda. Untuk konfigurasinya seperti ini.

### Pada Minastir
Pertama-tama, kita akan install bind9. Untuk kodenya seperti ini.
```
apt update
apt install bind9 -y
```
Selanjutnya, kita akan config file ini.
`etc/bind/named.conf.options`
```
options {
    directory "/var/cache/bind";

    // IP DNS publik yang jadi tujuan forwarder
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };

    allow-query { any; };         // izinkan semua client internal
    allow-recursion { any; };     // izinkan rekursi
    dnssec-validation auto;

    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};

```

Setelah itu, kita restart `bind9` dengan kode ini.
```
service named stop
named -g &
```

### Pada Client
Kita cukup konfigurasi `/etc/resolv.conf`. Untuk isinya seperti ini.
```
nameserver 10.78.5.2
```
Ini adalah IP dari Minastir.

### Uji Coba
Kita akn coba ping google dari client. Untuk kodenya seperti ini
```
ping google.com
```
Dan jika berhasil maka akan muncul seperti ini.

<img width="942" height="386" alt="Screenshot 2025-10-31 at 21 36 53" src="https://github.com/user-attachments/assets/f4420a38-eb80-4d82-9f7d-bb1a8391844c" />


## No. 4
Pada soal ini kita akan setting Erendis di `ns1.K29.com` dan Amdir di `ns2.K29.com`. Mula-mula, kita akan instal `bind9` di Erendis dan Amdir. Untuk commandnya seperti ini.
```
apt update
apt install bind9 -y
```
### Config Erendis
Selanjutnya, kita akan config pada beberapa file ini.
`/etc/bind/named.conf.local`
```
zone "K29.com" {
    type master;
    file "/etc/bind/db.K29";
    allow-transfer { 10.78.3.4; };  # Izinkan transfer ke Amdir (IP Slave)
    notify yes;                    # Beri tahu Slave saat ada update
};
```

`/etc/bind/db.K29`
```
$TTL    604800
@       IN      SOA     ns1.K29.com. root.K29.com. (
                     2025103101 ; Serial (UBAH INI SETIAP UPDATE)
                      604800     ; Refresh
                       86400     ; Retry
                     2419200     ; Expire
                      604800 )   ; Negative Cache TTL
;
@       IN      NS      ns1.K29.com.
@       IN      NS      ns2.K29.com.

ns1     IN      A       10.78.3.3
ns2     IN      A       10.78.3.4

; Record-record klien:
Palantir IN      A       10.78.4.3
Elros    IN      A       10.78.1.7
Pharazon IN      A       10.78.2.4
Elendil  IN      A       10.78.1.2
Isildur  IN      A       10.78.1.3
Anarion  IN      A       10.78.1.4
Galadriel IN     A       10.78.2.5
Celeborn IN      A       10.78.2.6
Oropher  IN      A       10.78.2.7
```
Setelah itu, cek apakah dia mempunyai serial atau tidak. Kita bisa cek dengan menggunakan kode ini.
```
named-checkzone K29.com /etc/bind/db.K29
```
Jika berhasil akan muncul seperti ini.

<img width="761" height="125" alt="Screenshot 2025-10-31 at 15 25 36" src="https://github.com/user-attachments/assets/3cbf0ba0-20ba-4299-a4c0-bf19878b7c01" />


Lalu, restart `bind9` menggunakan command ini.
```
/etc/init.d/named restart
```

### Config Amdir
Pada Amdir, kita akan konfigurasi file ini.
`/etc/bind/named.conf.local`
```
zone "K29.com" {
    type slave;
    file "/var/lib/bind/db.K29";  <-- Ganti dengan path ABSOLUT
    masters { 10.78.3.3; };
};
```
Lalu, restart `bind9` menggunakan command ini.
```
/etc/init.d/named restart
```

Setelah itu, tunggu selama beberapa saat. Jika transfer file dari Erendis ke Amdir berhasil, akan muncul seperti ini.
<img width="928" height="214" alt="Screenshot 2025-10-31 at 15 26 53" src="https://github.com/user-attachments/assets/67a80cf1-6202-4a86-b0ad-5e571e13044c" />

### Uji Coba
Selanjutnya, pada Erendis `/etc/bind/db.K29` kita akan merubah sedikit isinya, misalnya pada IP Pharazon. Sebelum itu, kita akan cek ip dari Pharazon di Amdir. Untuk kodenya seperti ini.
```
dig @10.78.3.4 Pharazon.K29.com
```
Dan untuk hasilnya seperti ini.

<img width="926" height="565" alt="Screenshot 2025-10-31 at 15 20 42" src="https://github.com/user-attachments/assets/388b040e-5142-46d2-ab43-97cc1ce5bf4d" />

Lalu, kita coba ubah isi dari `/etc/bind/db.K29` milik Erendis. Untuk isinya dapat diubah seperti ini.
```
$TTL    604800
@       IN      SOA     ns1.K29.com. root.K29.com. (
                     2025103102 ; Serial (Wajib diubah saat update)
                      604800     ; Refresh
                       86400     ; Retry
                     2419200     ; Expire
                      604800 )   ; Negative Cache TTL
;
@       IN      NS      ns1.K29.com.
@       IN      NS      ns2.K29.com.

ns1     IN      A       10.78.3.3  ; Erendis
ns2     IN      A       10.78.3.4  ; Amdir

; Record Klien yang Diberi Nama Domain Unik:
Palantir IN      A       10.78.4.3
Elros    IN      A       10.78.1.7
Pharazon IN      A       10.78.2.99
Elendil  IN      A       10.78.1.2
Isildur  IN      A       10.78.1.3
Anarion  IN      A       10.78.1.4
Galadriel IN     A       10.78.2.5
Celeborn IN      A       10.78.2.6
Oropher  IN      A       10.78.2.7
```
Note: Setiap ada perubahan/update, seriap wajib diubah (+1) agar perubahan dapat terlihat.

Jika sudah, restart `bind9` menggunakan command ini.
```
killall named 2>/dev/null
/usr/sbin/named -g &
```
Setelah itu, kita cek kembali untuk IP Pharazon, apakah ia sudah update. Untuk commandnya seperti ini.
```
dig @10.78.3.4 Pharazon.K29.com
```
Jika berhasil maka akan muncul seperti ini.

<img width="914" height="569" alt="Screenshot 2025-10-31 at 15 39 30" src="https://github.com/user-attachments/assets/ca6a3217-2746-40c9-9253-6730159e057f" />


## No. 5
Pada soal ini, mual-mula kita akan melakukan config pada Erendis dan Amdir. Untuk kodenya seperti ini.

### Erendis
Pada file ini kita akan menambahkan zone transfer. Untuk kodenya seperti ini.
`/etc/bind/named.conf.local`
```
zone "K29.com" {
    type master;
    file "/etc/bind/db.K29";
    allow-transfer { 10.78.3.4; };  # IP Amdir (Slave)
    notify yes;
};

zone "3.78.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.78.3";
    allow-transfer { 10.78.3.4; };
    notify yes;
};
```
Lalu, kita akan mencari forward lookup menggunakan file ini. 
`/etc/bind/db.K29`
```
$TTL    604800
@       IN      SOA     ns1.K29.com. root.K29.com. (
                     2025103109 ; Serial
                      604800     ; Refresh
                       86400     ; Retry
                     2419200     ; Expire
                      604800 )   ; Negative Cache TTL
;

; =====================
; NS Records (Name Servers)
; =====================
@       IN      NS      ns1.K29.com.
@       IN      NS      ns2.K29.com.

; =====================
; A Records (Address)
; =====================
ns1     IN      A       10.78.3.3
ns2     IN      A       10.78.3.4
@       IN      A       10.78.3.3       ; alamat utama domain K29.com

; =====================
; Aliases & TXT
; =====================
www     IN      CNAME   K29.com.
Elros   IN      TXT     "Cincin Sauron"
Pharazon        IN      TXT     "Aliansi Terakhir"
```
Selanjutnya, kita akan melakukan reverse lokup dengan 
`/etc/bind/db.10.78`
```
$TTL    604800
@       IN      SOA     ns1.K29.com. root.K29.com. (
                     2025103107 ; Serial
                      604800     ; Refresh
                       86400     ; Retry
                     2419200     ; Expire
                      604800 )   ; Negative Cache TTL
;
@       IN      NS      ns1.K29.com.
@       IN      NS      ns2.K29.com.

; Reverse PTR records
3       IN      PTR     Erendis.K29.com.
4       IN      PTR     Amdir.K29.com.
```
Lalu, restart `bind9` menggunakan command ini.
```
pkill named
named -u bind
```

### Amdir
Kita akan jadikan Amdir sebagai DNS Slave. Untuk kodenya seperti ini.
`nano /etc/bind/named.conf.local`
```
zone "K29.com" {
    type slave;
    masters { 10.78.3.3; };   # IP Erendis (master)
    file "db.K29";
};

zone "10.78.in-addr.arpa" {
    type slave;
    masters { 10.78.3.3; };   # IP Erendis (master)
    file "db.10.78";
};
```
Lalu, restart `bind` menggunakan command ini.
```
pkill named
named -u bind
```

### Pengujian
Untuk menguji apakah ia berhasil, kita dapat menggunakan 5 parameter berikut.
```
dig @10.78.3.3 K29.com
dig @10.78.3.4 K29.com
dig -x 10.78.3.3 @10.78.3.3
dig -x 10.78.3.4 @10.78.3.3
dig TXT Elros.K29.com @10.78.3.3
dig TXT Pharazon.K29.com @10.78.3.3
```
Jika berhasil maka akan muncul seperti ini.
#### dig @10.78.3.3 K29.com
![WhatsApp Image 2025-10-31 at 12 43 28](https://github.com/user-attachments/assets/22f5e020-16a3-40ab-a3a3-ae152dc764a8)


#### dig @10.78.3.4 K29.com
![WhatsApp Image 2025-10-31 at 12 43 42](https://github.com/user-attachments/assets/b4c7bd11-8dd4-462f-a633-7f457102564a)


#### dig -x 10.78.3.3 @10.78.3.3
![WhatsApp Image 2025-10-31 at 12 44 05](https://github.com/user-attachments/assets/a74de9ba-2923-4c8b-88ce-4c2d30e38f08)


#### dig -x 10.78.3.4 @10.78.3.3
![WhatsApp Image 2025-10-31 at 12 44 24](https://github.com/user-attachments/assets/f4608fa8-6ddf-41d5-96a0-6acf52aa9eb7)


#### dig TXT Elros.K29.com @10.78.3.3
![WhatsApp Image 2025-10-31 at 12 45 09](https://github.com/user-attachments/assets/d2169874-0a48-45a1-bcd5-ac131e4e2e98)


#### dig TXT Pharazon.K29.com @10.78.3.3
![WhatsApp Image 2025-10-31 at 12 49 12](https://github.com/user-attachments/assets/fb6aaa0d-ab2b-42d4-845f-2cb7fba65487)

## No. 6
Pada soal ini kita akan setting time untuk Dynamic IP keluarga manusia, peri dan seluruhnya. Kita akan config file `/etc/dhcp/dhcpd.conf`, dengan parameter sebagai berikut.

| Kebutuhan | Waktu (s) | DHCP Variable |
| --- | --- | --- |
| Global | 3600 | `max-lease-time` |
| Manusia | 1800 | `default-lease-time` |
| Peri | 600 | `default-lease-time` |

Lalu, tambahakn ke file `/etc/dhcp/dhcpd.conf`.
```
option domain-name "numenor.lab";
option domain-name-servers 10.78.3.2, 10.78.4.2; # Pindahkan ke global untuk keseragaman, atau biarkan di subnet
default-lease-time 600;
max-lease-time 3600;
authoritative;

# Subnet for Human Family (10.78.1.0/24)
subnet 10.78.1.0 netmask 255.255.255.0 {
    range 10.78.1.6 10.78.1.34;
    range 10.78.1.68 10.78.1.94;

    # Klien akan menggunakan Durin (10.78.1.1) sebagai gateway
    option routers 10.78.1.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.1.255;
    option domain-name-servers 10.78.3.2, 10.78.4.2;

    default-lease-time 1800;
}

# Subnet for Elf Family (10.78.2.0/24)
subnet 10.78.2.0 netmask 255.255.255.0 {
    range 10.78.2.35 10.78.2.67;
    range 10.78.2.96 10.78.2.121;

    # Klien akan menggunakan Durin (10.78.2.1) sebagai gateway
    option routers 10.78.2.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.2.255;
    option domain-name-servers 10.78.3.2, 10.78.4.2;

    default-lease-time 600;
}

# Subnet untuk jaringan Aldarion (server DHCP)
subnet 10.78.4.0 netmask 255.255.255.0 {
    range 10.78.4.10 10.78.4.20;
    option routers 10.78.4.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.4.255;
    option domain-name-servers 10.78.3.2, 10.78.4.2;

    # Tidak perlu lease-time karena IP statis/server
}

# Fixed address for Khamul (di subnet 10.78.3.0/24)
host khamul {
    hardware ethernet 02:42:ab:01:c2:00;
    fixed-address 10.78.3.95;

    # Khamul juga harus tahu gateway dan DNS
    option routers 10.78.3.1;
    option domain-name-servers 10.78.3.2, 10.78.4.2;
}
```

## No. 7
Kita akan menginstal php84, composer dan nginx pada Ksatria Númenor. Untuk Instalasinya seperti ini.

### Elendil, Isdilur, Anarion
```
apt update

## /root/install_laravel.sh

#!/bin/bash

# Update
apt update
apt upgrade -y

# Install nginx, php, dan dependencies
apt install -y nginx curl wget git

# Tambah repository PHP 8.4
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.4 php8.4-fpm php8.4-mysql php8.4-xml php8.4-curl php8.4-zip php8.4-mbstring php8.4-gd

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Start services tanpa systemctl
service nginx start
service php8.4-fpm start
```


### ke 2

```
#!/bin/bash
echo "=== Fix Composer untuk PHP 8.4 ==="

cd /var/www/laravel-app

# Hapus vendor dan composer.lock yang lama
rm -rf vendor
rm -f composer.lock

# Update composer.json untuk kompatibel dengan PHP 8.4
cat > composer.json << 'EOF'
{
    "name": "laravel/laravel",
    "type": "project",
    "description": "Laravel Simple REST API",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "require": {
        "php": "^8.1",
        "guzzlehttp/guzzle": "^7.2",
        "laravel/framework": "^10.10",
        "laravel/sanctum": "^3.2",
        "laravel/tinker": "^2.8"
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "laravel/pint": "^1.0",
        "laravel/sail": "^1.18",
        "mockery/mockery": "^1.4.4",
        "nunomaduro/collision": "^7.0",
        "phpunit/phpunit": "^10.1",
        "spatie/laravel-ignition": "^2.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# Install ulang dependencies
composer install --no-dev --optimize-autoloader

# Setup permissions dan .env
chown -R www-data:www-data /var/www/laravel-app
chmod -R 775 storage bootstrap/cache

cp .env.example .env
php artisan key:generate

echo "=== Composer fixed untuk PHP 8.4 ==="

chmod +x /root/fix_composer.sh
/root/fix_composer.sh
```


```
## /root/setup_laravel.sh

#!/bin/bash

# Hapus default nginx
rm -rf /var/www/html/*

# Clone project
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git
mv laravel-simple-rest-api laravel-app
cd laravel-app

# Install dependencies
composer install --no-dev

# Set permissions
chown -R www-data:www-data /var/www/laravel-app
chmod -R 775 storage bootstrap/cache

# Setup .env
cp .env.example .env
php artisan key:generate
```






```
## /etc/nginx/sites-available/Laravel

server {
    listen 80;
    server_name _;
    root /var/www/laravel-app/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```





## /root/configure_nginx.sh
```
#!/bin/bash

# Backup default config
cp /etc/nginx/sites-available/laravel /etc/nginx/sites-available/laravel.backup

# Copy config kita
cat > /etc/nginx/sites-available/laravel << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/laravel-app/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test dan restart nginx
nginx -t
service nginx restart
service php8.4-fpm restart





chmod +x /root/install_laravel.sh
chmod +x /root/setup_laravel.sh
chmod +x /root/configure_nginx.sh

/root/install_laravel.sh
/root/setup_laravel.sh
/root/configure_nginx.sh
```

## No. 8

Palantir – Install MariaDB dan Buat Database

# Login ke Palantir
ssh root@10.78.4.3

# Update package list
apt update

# Install MariaDB
apt install -y mariadb-server mariadb-client

# Start MariaDB (jika systemctl tidak ada, jalankan manual)
mysqld_safe --datadir=/var/lib/mysql &

# Masuk ke MariaDB
mysql -u root

# Set password root (jika belum)
ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpassword';
FLUSH PRIVILEGES;

# Buat database Laravel
CREATE DATABASE ikan;

### Buat user laravel dengan akses dari semua host
#CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravelpassword';
#GRANT ALL PRIVILEGES ON ikan.* TO 'laravel'@'%';
#FLUSH PRIVILEGES;

mysql -u root -p
CREATE USER 'laravel2'@'%' IDENTIFIED BY 'passwordBaru123';

-- Beri semua akses ke database ikan
GRANT ALL PRIVILEGES ON ikan.* TO 'laravel2'@'%';

-- Apply perubahan
FLUSH PRIVILEGES;

EXIT;

# Edit konfigurasi MariaDB supaya bisa diakses dari node lain
nano /etc/mysql/mariadb.conf.d/50-server.cnf
# Ganti:
# bind-address = 0.0.0.0

# Restart MariaDB
# Jika systemctl: systemctl restart mariadb
# Jika manual: killall mysqld; /usr/sbin/mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &






2. Worker Nodes (Elendil, Isildur, Anarion) – Install Nginx + PHP + Laravel

# Login ke tiap worker
ssh root@<worker-ip>

# Update package list
apt update

# Install Nginx dan PHP
apt install -y nginx php-fpm php-mysql php-cli php-xml composer unzip curl

# Buat folder Laravel
mkdir -p /var/www/blueprint
cd /var/www/blueprint

# Download Laravel
# composer create-project laravel/laravel .

# Set folder permission
chown -R www-data:www-data /var/www/blueprint
chmod -R 755 /var/www/blueprint

# Copy .env dan update koneksi DB
nano .env
# Set:
DB_CONNECTION=mysql
DB_HOST=10.78.4.3
DB_PORT=3306
DB_DATABASE=ikan
DB_USERNAME=laravel
DB_PASSWORD=laravelpassword

# Download MySQL
apt update
apt install -y mariadb-server


# Test koneksi database
mysql -u laravel -p -h 10.78.4.3 ikan
# Masukkan password laravelpassword



3. Jalankan Migration Laravel

# Masih di folder Laravel
php artisan migrate
Jika muncul:
INFO  Nothing to migrate.
berarti database sudah siap




4. Cek PHP + Nginx

### Buat file info.php
echo "<?php phpinfo(); ?>" > /var/www/blueprint/public/info.php

### Jalankan curl untuk cek PHP info
curl http://localhost:8001/info.php
### Harus tampil halaman phpinfo




5. Worker Nodes Lain


### Login ke Isildur & Anarion
ssh root@10.78.1.3
ssh root@10.78.1.4

### Pastikan folder Laravel sama
cd /var/www/blueprint

### Jalankan migration test
php artisan migrate




## No. 9
Elendil
```
#!/bin/bash
echo "=== Testing Laravel Workers ==="

WORKERS=("elendil.k01.com:8001" "isildur.k01.com:8002" "anarion.k01.com:8003")

for worker in "${WORKERS[@]}"; do
    echo "Testing $worker..."
    
    # Test halaman utama
    echo "=== Lynx $worker ==="
    lynx -dump http://$worker | head -20
    
    # Test API endpoint
    echo "=== API $worker/api/airing ==="
    curl -s http://$worker/api/airing | head -5
    
    echo "----------------------------------------"
done

echo "=== Testing completed ==="
```
```
# Check service di worker
service nginx status
service php8.4-fpm status

# Check koneksi database dari worker
cd /var/www/laravel-app
php artisan tinker
>>> DB::connection()->getPdo()
```


# Edit konfigurasi untuk pastikan pakai 127.0.0.1:9000
cat > /etc/nginx/sites-available/laravel << 'EOF'
server {
    listen 8001;
    server_name elendil.k29.com;
    root /var/www/laravel-app/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
```
```
# Install lynx dan curl jika belum
apt update && apt install -y lynx curl

# Test ke Elendil
lynx http://elendil.k01.com:8001

# Test API endpoint
curl http://elendil.k01.com:8001/api/airing
```

