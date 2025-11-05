no 17.


#dari client (Amandil)??


#!/bin/bash
echo "=== SOAL 17: BENCHMARK & FAILOVER TEST ==="

# Install apache2-utils untuk ab
apt update && apt install -y apache2-utils

echo "1. Benchmark Load Balancer:"
ab -n 100 -c 10 -A noldor:silvan http://pharazon.k29.com/

echo ""
echo "2. Monitor distribusi request:"
for i in {1..10}; do
    curl -s -u noldor:silvan http://pharazon.k29.com/ | grep "Halo dari"
done

echo ""
echo "3. Simulasi worker down (Galadriel)..."
echo "   Akses Galadriel dan jalankan: nginx -s stop"
echo ""
echo "4. Benchmark setelah failover:"
ab -n 50 -c 5 -A noldor:silvan http://pharazon.k29.com/

echo ""
echo "5. Test failover manual:"
for i in {1..6}; do
    curl -s -u noldor:silvan http://pharazon.k29.com/ | grep "Halo dari"
done

echo ""
echo "=== SOAL 17 SELESAI ==="
echo "Check log Pharazon: tail -f /var/log/nginx/access.log"


Akses Pharazon dan monitor log:

# Monitor log real-time
tail -f /var/log/nginx/access.log

# Check error log jika ada masalah
tail -f /var/log/nginx/error.log

