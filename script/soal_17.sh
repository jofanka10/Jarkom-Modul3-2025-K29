#BENCHMARK PHP + FAILOVER TEST

#Node: Client (Miriel/Celebrimbor)

nano /root/benchmark_php_17.sh

#!/bin/bash
echo "=== Soal 17: Benchmark PHP + Failover Test ==="

apt update && apt install -y apache2-utils

# Tambahkan hosts
echo "10.78.2.4 pharazon.k29.com" >> /etc/hosts

echo "1. Benchmark dengan auth:"
ab -n 100 -c 10 -A noldor:silvan http://pharazon.k29.com/

echo "2. Simulasi worker down (stop nginx di Galadriel dulu)"
echo "3. Benchmark lagi:"
ab -n 100 -c 10 -A noldor:silvan http://pharazon.k29.com/

echo "=== Soal 17 selesai ==="