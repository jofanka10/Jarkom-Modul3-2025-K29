# Erendis

/etc/bind/named.conf.local
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

/etc/bind/db.K29
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

/etc/bind/db.10.78
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

pkill named
named -u bind

# Amdir
nano /etc/bind/named.conf.local
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

pkill named
named -u bind

# pengujian

dig @10.78.3.3 K29.com
dig @10.78.3.4 K29.com
dig -x 10.78.3.3 @10.78.3.3
dig -x 10.78.3.4 @10.78.3.3
dig TXT Elros.K29.com @10.78.3.3
dig TXT Pharazon.K29.com @10.78.3.3
