#!/bin/sh
echo "hi - test in nginx-entrypoint.sh"
# docker-entrypoint.sh  /etc/nginx/nginx.conf
nginx -c /etc/nginx/nginx.conf 
tail -f /dev/null