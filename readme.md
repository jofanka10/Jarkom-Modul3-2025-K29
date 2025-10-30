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
Lalu, kita akan melakukan config pada `/etc/dhcp/dhcod.conf`. Untuk confignya seperti ini.
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

### Minastir
Mula-mula, kita akan instal `nginx`.
```
apt update
apt install nginx
```
Setelah itu, kita config pada file `/etc/nginx/conf.d/forward_proxy.conf`. Untuk kodenya seperti ini.
`/etc/nginx/conf.d/forward_proxy.conf`
```
server {
    listen 8080 default_server; # Jadikan ini server default untuk port 8080
    server_name _;              # Gunakan underscore sebagai server catch-all
    
    # KOREKSI SUBET IP HARUS BENAR 
    allow 10.78.1.0/24;
    allow 10.78.2.0/24;
    allow 10.78.3.0/24;
    allow 10.78.4.0/24;
    allow 10.78.5.0/24;
    deny all; 

if ($host = "www.facebook.com") {
        return 403;
    }
    
    # Tambahkan host tanpa 'www.' juga, karena curl mengakses 'facebook.com'
    if ($host = "facebook.com") {
        return 403;
    }

    
    location / {
        # *** Mengatasi Masalah Host dan Resolusi ***
        resolver 8.8.8.8; 
        
        # Ambil host tujuan dari header HTTP
        set $target_host $http_host; 
        
        # Gunakan Host header sebagai URL proxy
        proxy_pass http://$target_host; 

        # Tambahkan ini untuk menghindari konflik header:
        proxy_set_header Host $target_host;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Connection "";
    }
}

```

```
nginx -t
kill -HUP $(cat /var/run/nginx.pid)
```


### Konfigurasi di Durin

Untuk memastikan, kita dapat melakukan konfigurasi awal pada Durin. Untuk kodenya seperti ini.
```
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -F
```

Kita akan terapkan Masquerade menggunakan iptables. Untuk kodenya seperti ini.
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

Selanjutnya, kita akan menerapkan DNAT agar pesan yang dikirim dari node client melewati Minastir. Untuk kodenya seperti ini.
```
# Subnet 10.78.1.x
iptables -t nat -A PREROUTING -s 10.78.1.0/24 -p tcp --dport 80 -j DNAT --to-destination 10.78.5.2:8080
iptables -t nat -A PREROUTING -s 10.78.1.0/24 -p tcp --dport 443 -j DNAT --to-destination 10.78.5.2:8080

# Subnet 10.78.2.x
iptables -t nat -A PREROUTING -s 10.78.2.0/24 -p tcp --dport 80 -j DNAT --to-destination 10.78.5.2:8080
iptables -t nat -A PREROUTING -s 10.78.2.0/24 -p tcp --dport 443 -j DNAT --to-destination 10.78.5.2:8080

# Subnet 10.78.3.x
iptables -t nat -A PREROUTING -s 10.78.3.0/24 -p tcp --dport 80 -j DNAT --to-destination 10.78.5.2:8080
iptables -t nat -A PREROUTING -s 10.78.3.0/24 -p tcp --dport 443 -j DNAT --to-destination 10.78.5.2:8080

# Subnet 10.78.4.x
iptables -t nat -A PREROUTING -s 10.78.4.0/24 -p tcp --dport 80 -j DNAT --to-destination 10.78.5.2:8080
iptables -t nat -A PREROUTING -s 10.78.4.0/24 -p tcp --dport 443 -j DNAT --to-destination 10.78.5.2:8080
```
### Kode di Client

Pada client, kita dapat melakukan export ke HTTP proxy dan HTTPS proxy. Untuk kodenya seperti ini.
```
export http_proxy="http://10.78.5.2:8080"
export https_proxy="http://10.78.5.2:8080"
```
### Otomatisasi Kode pada Client
`/etc/environment`
```
HTTP_PROXY="http://10.78.5.2:8080"
HTTPS_PROXY="http://10.78.5.2:8080"
```
