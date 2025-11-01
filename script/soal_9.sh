#TESTING WORKER

#Node: Elendil, Isildur, Anarion

nano /root/soal9_test_worker.sh

#!/bin/bash
echo "=== SOAL 9: TESTING WORKER ==="

# Deteksi port
HOSTNAME=$(hostname)
case $HOSTNAME in
    "Elendil") PORT=8001 ;;
    "Isildur") PORT=8002 ;;
    "Anarion") PORT=8003 ;;
    *) PORT=8000 ;;
esac

echo "=== Testing worker $HOSTNAME ==="

# Test local
echo "1. Test local:"
curl -s http://localhost:$PORT | head -5

echo "2. Test API:"
curl -s http://localhost:$PORT/api/airing | head -5

echo "3. Test koneksi database:"
cd /var/www/laravel-app
php artisan tinker --execute="echo DB::connection()->getPdo() ? 'Database OK' : 'Database ERROR';"

echo "=== SOAL 9 SELESAI ==="


#SCRIPT DATABASE (PALANTIR)
#Node: Palantir

nano /root/setup_database.sh

#!/bin/bash
echo "=== SETUP DATABASE DI PALANTIR ==="

apt update && apt install -y mariadb-server
service mariadb start

mysql -e "CREATE DATABASE laravel_db;"
mysql -e "CREATE USER 'laravel_user'@'%' IDENTIFIED BY 'password123';"
mysql -e "GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'%';"
mysql -e "FLUSH PRIVILEGES;"

sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
service mariadb restart

echo "=== DATABASE SIAP ==="