#DATABASE REPLIKASI

#Node: Palantir (Master) & Narvi (Slave)

#Script Palantir:
nano /root/setup_db_master_18.sh

#!/bin/bash
echo "=== Soal 18: Setup Database Master ==="

# Edit config MariaDB sebagai master
cat >> /etc/mysql/mariadb.conf.d/50-server.cnf << 'EOF'

# Replication Master Config
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = laravel_db
EOF

# Restart MySQL
pkill mysqld
sleep 2
mysqld_safe &

# Buat user replication
sleep 5
mysql -e "CREATE USER 'repl_user'@'%' IDENTIFIED BY 'replpass';"
mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "FLUSH TABLES WITH READ LOCK;"
mysql -e "SHOW MASTER STATUS;"

echo "=== Master database configured ==="


#Script Narvi:

nano /root/setup_db_slave_18.sh

#!/bin/bash
echo "=== Soal 18: Setup Database Slave ==="

# Install MariaDB
apt update && apt install -y mariadb-server

# Edit config sebagai slave
cat >> /etc/mysql/mariadb.conf.d/50-server.cnf << 'EOF'

# Replication Slave Config
server-id = 2
relay-log = /var/log/mysql/mysql-relay-bin.log
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = laravel_db
EOF

# Restart MySQL
pkill mysqld
sleep 2
mysqld_safe &

# Setup replication
sleep 5
mysql -e "CHANGE MASTER TO MASTER_HOST='10.78.4.3', MASTER_USER='repl_user', MASTER_PASSWORD='replpass', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=123;"
mysql -e "START SLAVE;"
mysql -e "SHOW SLAVE STATUS\G"

echo "=== Slave database configured ==="

