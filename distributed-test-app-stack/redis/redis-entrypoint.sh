#!/bin/sh
CONF_FILE=/etc/redis/redis.conf

if [ ! -f $CONF_FILE ] 
then
echo "appendonly yes" > $CONF_FILE	
echo "protected-mode no" > $CONF_FILE	
if [ -n "$REDIS_MASTER_SERVICENAME" ]; then echo "slaveof $REDIS_MASTER_SERVICENAME ${REDIS_MASTER_PORT:-6379}" >> $CONF_FILE;
else 
echo "bind 0.0.0.0" >> $CONF_FILE
fi
chown redis:redis $CONF_FILE
fi

exec docker-entrypoint.sh redis-server /etc/redis/redis.conf