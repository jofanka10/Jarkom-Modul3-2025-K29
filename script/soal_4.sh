# Pada Erendis dan Amdir

apt update
apt install bind9 -y

# Erendis

/etc/bind/named.conf.local
zone "K29.com" {
    type master;
    file "/etc/bind/db.K29";
    allow-transfer { 10.78.3.4; };  # Izinkan transfer ke Amdir (IP Slave)
    notify yes;                    # Beri tahu Slave saat ada update
};

/etc/bind/db.K29
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

named-checkzone K29.com /etc/bind/db.K29

/etc/init.d/named restart

/etc/bind/named.conf.local
zone "K29.com" {
    type slave;
    file "/var/lib/bind/db.K29";  <-- Ganti dengan path ABSOLUT
    masters { 10.78.3.3; };
};

/etc/init.d/named restart

dig @10.78.3.4 Pharazon.K29.com

# Erendis

/etc/bind/db.K29

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

killall named 2>/dev/null
/usr/sbin/named -g &

dig @10.78.3.4 Pharazon.K29.com
