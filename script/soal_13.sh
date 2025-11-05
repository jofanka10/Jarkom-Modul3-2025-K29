# Buat test PHP di masing-masing worker
# Di Galadriel:
echo '<?php echo "PHP Test: " . gethostname() . " - Time: " . date("H:i:s"); ?>' > /var/www/html/test.php

# Test dari client
curl http://galadriel.k29.com:8004/test.php
