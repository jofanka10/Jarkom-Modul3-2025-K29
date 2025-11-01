#Node: Miriel (10.78.1.5)

nano /root/benchmark_laravel.sh

#!/bin/bash
echo "=== Benchmark Load Balancer Laravel ==="

# Install apache2-utils untuk ab
apt update && apt install -y apache2-utils

# Tambahkan hosts sementara
echo "10.78.1.7 elros.k29.com" >> /etc/hosts

echo "1. Serangan Awal:"
ab -n 100 -c 10 http://elros.k29.com/api/airing/

echo "2. Serangan Penuh:"
ab -n 2000 -c 100 http://elros.k29.com/api/airing/

echo "=== Benchmark selesai ==="