# Minastir
apt install nginx -y

cat > nginx_proxy_config.sh << EOF
#!/bin/bash

# Pastikan Anda menjalankan ini di Minastir!

# Tulis konten konfigurasi Nginx ke file forward_proxy.conf
cat > /etc/nginx/conf.d/forward_proxy.conf << 'NGINX_CONF'
server {
    listen 8080 default_server;
    server_name _;
    
    # Aturan Pemeriksaan: Blokir facebook.com
    # Catatan: Aturan ini sering gagal di Transparent Proxy dan harus dipindahkan ke location /
    if (\$host = "www.facebook.com") {
        return 403;
    }
    if (\$host = "facebook.com") {
        return 403;
    }

    location / {
        # Gunakan DNS Durin/Valinor
        resolver 192.168.122.1; 
        
        set \$target_host \$http_host; 
        proxy_pass http://\$target_host; 

        # Header yang diperlukan untuk forward proxy
        proxy_set_header Host \$target_host;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header Connection "";
    }
}
NGINX_CONF

# Uji sintaks Nginx
nginx -t

# Muat ulang (reload) Nginx agar konfigurasi baru berlaku
service nginx reload
# atau
# systemctl reload nginx

echo "Konfigurasi Nginx di Minastir telah diperbarui dan layanan telah di-reload."
EOF

apt install dnsmasq -y

cat > dnsmasq_config.sh << EOF
#!/bin/bash

# Pastikan Anda menjalankan ini di Minastir!

# Tulis konten konfigurasi dnsmasq ke file /etc/dnsmasq.conf
cat > /etc/dnsmasq.conf << 'DNSMASQ_CONF'
# Konfigurasi DNS Forwarder untuk Minastir (10.78.5.2)
listen-address=127.0.0.1,10.78.5.2
server=192.168.122.1
interface=eth0,eth1,eth2,eth3,eth4,eth5
DNSMASQ_CONF

# Restart layanan dnsmasq agar konfigurasi baru berlaku
service dnsmasq restart
# atau jika service gagal:
# killall dnsmasq
# /usr/sbin/dnsmasq -C /etc/dnsmasq.conf

echo "Konfigurasi dnsmasq di Minastir telah diperbarui dan layanan telah di-restart."
EOF

# Durin
echo 1 > /proc/sys/net/ipv4/ip_forward
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

## Mengalihkan HTTP (Port 80) dari seluruh subnet 10.78.x.x ke Minastir:8080
iptables -t nat -A PREROUTING \
-s 10.78.0.0/16 \
-p tcp --dport 80 \
-d ! 10.78.0.0/16 \
-j DNAT --to-destination 10.78.5.2:8080

## Mengalihkan HTTPS (Port 443) ke Minastir:8080
iptables -t nat -A PREROUTING \
-s 10.78.0.0/16 \
-p tcp --dport 443 \
-d ! 10.78.0.0/16 \
-j DNAT --to-destination 10.78.5.2:8080

iptables -t nat -F

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Aldarion

cat > dhcpd_config.sh << EOF
#!/bin/bash

# Pastikan Anda menjalankan ini di Aldarion!

# Tulis konten konfigurasi DHCP ke file dhcpd.conf
cat > /etc/dhcp/dhcpd.conf << 'DHCP_CONF'
option domain-name "numenor.lab";
option domain-name-servers 10.78.5.2;
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
    option domain-name-servers 10.78.5.2;

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
    option domain-name-servers 10.78.5.2;

    default-lease-time 600;
    max-lease-time 3600;
}

# Subnet untuk jaringan Aldarion (server DHCP)
subnet 10.78.4.0 netmask 255.255.255.0 {
    range 10.78.4.10 10.78.4.20;
    option routers 10.78.4.1;

    # Tambahan dari template yang diminta
    option broadcast-address 10.78.4.255;
    option domain-name-servers 10.78.5.2;

    # Tidak perlu lease-time karena IP statis/server
}

# Fixed address for Khamul (di subnet 10.78.3.0/24)
host khamul {
    hardware ethernet 02:42:ab:01:c2:00;
    fixed-address 10.78.3.95;

    # Khamul juga harus tahu gateway dan DNS
    option routers 10.78.3.1;
    option domain-name-servers 10.78.5.2;
}
DHCP_CONF

# Restart layanan DHCP Server
service isc-dhcp-server restart
# atau
# systemctl restart isc-dhcp-server

echo "Konfigurasi DHCPD di Aldarion telah diperbarui dan layanan telah di-restart."
EOF

service isc-dhcp-server restart

up echo nameserver 10.78.5.2 > /etc/resolv.conf


# Uji Coba
dig google.com
curl http://facebook.com
