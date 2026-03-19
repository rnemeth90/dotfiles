while true; do echo | openssl s_client -connect us1-g660.labs.aprimo.com:443 -servername us1-g660.labs.aprimo.com 2>/dev/null | grep -q "Verify return code: 0 (ok)" && echo "[$(date)] success" || echo "[$(date)] fail";  sleep 1; done  |tee ./nginx-tls-log

