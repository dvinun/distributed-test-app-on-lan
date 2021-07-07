#!/bin/bash
echo "--------------------------------------------------------------------------------------------------------------"
echo "distributed-test-app-stack DEPLOYMENT                                                                           "
echo "--------------------------------------------------------------------------------------------------------------"

echo $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14}

export SENTINEL_HOSTNAME=$1 
export SENTINEL_SERVICENAME=$2 
export SENTINEL_IP=`sudo docker node inspect --format {{.Status.Addr}} $SENTINEL_HOSTNAME`

export REDIS_MASTER_HOSTNAME=$3
export REDIS_MASTER_SERVICENAME=$4
export REDIS_MASTER_IP=`sudo docker node inspect --format {{.Status.Addr}} $REDIS_MASTER_HOSTNAME`

export REDIS_SLAVE_NODE1_HOSTNAME=$5 
export REDIS_SLAVE_NODE1_SERVICENAME=$6 

export REDIS_SLAVE_NODE2_HOSTNAME=$7 
export REDIS_SLAVE_NODE2_SERVICENAME=$8 

export RABBITMQ_MASTER_HOSTNAME=$9
export RABBITMQ_MASTER_SERVICENAME=${10}

export RABBITMQ_SLAVE_NODE1_HOSTNAME=${11}
export RABBITMQ_SLAVE_NODE1_SERVICENAME=${12} 

export RABBITMQ_SLAVE_NODE2_HOSTNAME=${13} 
export RABBITMQ_SLAVE_NODE2_SERVICENAME=${14} 

echo "SENTINEL_HOSTNAME: " $SENTINEL_HOSTNAME 
echo "SENTINEL_SERVICENAME: " $SENTINEL_SERVICENAME 
echo "SENTINEL_IP: " $SENTINEL_IP 

echo "REDIS_MASTER_HOSTNAME: " $REDIS_MASTER_HOSTNAME
echo "REDIS_MASTER_SERVICENAME: " $REDIS_MASTER_SERVICENAME
echo "REDIS_MASTER_IP: " $REDIS_MASTER_IP 

echo "REDIS_SLAVE_NODE1_HOSTNAME: " $REDIS_SLAVE_NODE1_HOSTNAME 
echo "REDIS_SLAVE_NODE1_SERVICENAME: " $REDIS_SLAVE_NODE1_SERVICENAME 

echo "REDIS_SLAVE_NODE2_HOSTNAME: " $REDIS_SLAVE_NODE2_HOSTNAME 
echo "REDIS_SLAVE_NODE2_SERVICENAME: " $REDIS_SLAVE_NODE2_SERVICENAME 

echo "RABBITMQ_MASTER_HOSTNAME: " $RABBITMQ_MASTER_HOSTNAME 
echo "RABBITMQ_MASTER_SERVICENAME: " $RABBITMQ_MASTER_SERVICENAME 

echo "RABBITMQ_SLAVE_NODE1_HOSTNAME: " $RABBITMQ_SLAVE_NODE1_HOSTNAME 
echo "RABBITMQ_SLAVE_NODE1_SERVICENAME: " $RABBITMQ_SLAVE_NODE1_SERVICENAME 

echo "RABBITMQ_SLAVE_NODE2_HOSTNAME: " $RABBITMQ_SLAVE_NODE2_HOSTNAME 
echo "RABBITMQ_SLAVE_NODE2_SERVICENAME: " $RABBITMQ_SLAVE_NODE2_SERVICENAME 

if [ -z $SENTINEL_HOSTNAME ] || [ -z $REDIS_MASTER_HOSTNAME ] || [ -z $REDIS_SLAVE_NODE1_HOSTNAME ]  || [ -z $REDIS_SLAVE_NODE2_HOSTNAME ] ; then
  echo "Status: Arguments missing. Cannot continue to build the stack. Missing SENTINEL_HOSTNAME, REDIS_MASTER_HOSTNAME, REDIS_SLAVE_NODE1_HOSTNAME, REDIS_SLAVE_NODE1_HOSTNAME" >&2
  exit 1;
fi

echo "1- Start to push on registry the redis docker image which can be used as master or slave in the stack..."
sudo docker-compose -f redis/redis-docker-compose.yml build
sudo docker-compose -f redis/redis-docker-compose.yml push
echo "(1)End to build and push redis image to registry."
echo "-------------------------------------------------------\n"

echo "2- Start to push on registry the redis docker image which will be used to build sentinel..."
sudo docker-compose -f sentinel/sentinel-docker-compose.yml build
sudo docker-compose -f sentinel/sentinel-docker-compose.yml push
echo "(2)End to build and push redis sentinel image to registry."
echo "-------------------------------------------------------\n"

echo "3- Start to push our test api example on the registry..."
sudo docker-compose -f test-api/test-api-docker-compose.yml build
sudo docker-compose -f test-api/test-api-docker-compose.yml push
echo "(3)End to push our test api example on the registry."
echo "-------------------------------------------------------\n"

echo "4- Start to push rabbit-mq on the registry..."
sudo docker-compose -f rabbitmq/rabbitmq-docker-compose.yml build
sudo docker-compose -f rabbitmq/rabbitmq-docker-compose.yml push
echo "(4)End to push rabbit-mq on the registry."
echo "-------------------------------------------------------\n"

echo "5- Start to push nginx on the registry..."
sudo docker-compose -f nginx/nginx-docker-compose.yml build
sudo docker-compose -f nginx/nginx-docker-compose.yml push
echo "(5)End to push nginx on the registry."
echo "-------------------------------------------------------\n"

echo "6- Start to deploy the stack..."


echo "************ REDIS *************"
echo "Sentinel hostname and IP: $SENTINEL_HOSTNAME -  $SENTINEL_IP"
echo "Redis Master hostname and IP: $REDIS_MASTER_HOSTNAME - $REDIS_MASTER_IP"
echo "Redis slave 1 hostname: $REDIS_SLAVE_NODE1_HOSTNAME"
echo "Redis slave 2 hostname: $REDIS_SLAVE_NODE2_HOSTNAME"
echo "************ RABBITMQ *************"
echo "RabbitMQ Master hostname: $RABBITMQ_MASTER_HOSTNAME"
echo "RabbitMQ cluster 1 hostname: $RABBITMQ_SLAVE_NODE1_HOSTNAME"
echo "RabbitMQ cluster 2 hostname: $RABBITMQ_SLAVE_NODE2_HOSTNAME"

sudo \
SENTINEL_HOSTNAME=$SENTINEL_HOSTNAME \
SENTINEL_SERVICENAME=$SENTINEL_SERVICENAME \
SENTINEL_IP=$SENTINEL_IP \
REDIS_MASTER_HOSTNAME=$REDIS_MASTER_HOSTNAME \
REDIS_MASTER_SERVICENAME=$REDIS_MASTER_SERVICENAME \
REDIS_MASTER_IP=$REDIS_MASTER_IP \
REDIS_SLAVE_NODE1_HOSTNAME=$REDIS_SLAVE_NODE1_HOSTNAME \
REDIS_SLAVE_NODE1_SERVICENAME=$REDIS_SLAVE_NODE1_SERVICENAME \
REDIS_SLAVE_NODE2_HOSTNAME=$REDIS_SLAVE_NODE2_HOSTNAME \
REDIS_SLAVE_NODE2_SERVICENAME=$REDIS_SLAVE_NODE2_SERVICENAME \
RABBITMQ_MASTER_HOSTNAME=$RABBITMQ_MASTER_HOSTNAME \
RABBITMQ_MASTER_SERVICENAME=$RABBITMQ_MASTER_SERVICENAME \
RABBITMQ_SLAVE_NODE1_HOSTNAME=$RABBITMQ_SLAVE_NODE1_HOSTNAME \
RABBITMQ_SLAVE_NODE1_SERVICENAME=$RABBITMQ_SLAVE_NODE1_SERVICENAME \
RABBITMQ_SLAVE_NODE2_HOSTNAME=$RABBITMQ_SLAVE_NODE2_HOSTNAME \
RABBITMQ_SLAVE_NODE2_SERVICENAME=$RABBITMQ_SLAVE_NODE2_SERVICENAME \
docker stack deploy -c distributed-test-app-stack-docker-compose.yml distributed-test-app-stack

printf "(5)End to deploy the stack... Please wait until the services started\n\n\n"

sleep 3s

printf "Status: The stack deployment has been completed.\n\n"

sudo docker service ls
printf "If all services replicas are not already deployed, please run << docker service ls >> to see if it now completed.\n"