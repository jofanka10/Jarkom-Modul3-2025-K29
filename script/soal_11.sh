### Amandil

echo "nameserver 10.78.5.2" > /etc/resolv.conf

apt update && apt install apache2-utils -y

echo "nameserver 10.78.3.3" > /etc/resolv.conf

ab -n 100 -c 10 http://elros.K29.com/api/airing/


ab -n 2000 -c 100 http://elros.K29.com/api/airing/



### Node Worker

apt update && apt install htop -y


htop


