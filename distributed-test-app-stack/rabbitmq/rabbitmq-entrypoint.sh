#!/bin/bash

# Please ignore the commented lines. They are just there for troubleshooting. 
 
set -e

HOSTNAME=`env hostname`

echo "HOSTNAME " $HOSTNAME
echo ""
echo "Starting RabbitMQ Server For host:" $HOSTNAME

# If not clustered then start it normally as standalone server
if [ -z "$CLUSTERED" ]; then
	# Start RMQ from entry point.
	# This will ensure that environment variables passed
	# will be honored
	echo "docker-entrypoint.sh rabbitmq-server"
	docker-entrypoint.sh rabbitmq-server 

	echo "tail -f /var/log/rabbitmq/*.log"
    tail -f /var/log/rabbitmq/*.log
else	
	# Start RMQ from entry point.
	# This will ensure that environment variables passed
	# will be honored
	echo "docker-entrypoint.sh rabbitmq-server -detached"
	docker-entrypoint.sh rabbitmq-server -detached
	    
	echo "rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\@$HOSTNAME.pid"
	rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\@$HOSTNAME.pid
	
	echo "rabbitmqctl status"
    rabbitmqctl status
	
	echo "rabbitmqctl cluster_status"
	rabbitmqctl cluster_status
	
	echo "rabbitmqctl stop_app"
	rabbitmqctl stop_app
	
	# echo "rabbitmqctl forget_cluster_node rabbit"@$CLUSTER_WITH
	# rabbitmqctl forget_cluster_node rabbit@$CLUSTER_WITH
	
	# echo "rabbitmqctl reset"
	# rabbitmqctl reset
	
	if [ -z "$RAM_NODE" ]; then
       echo "rabbitmqctl join_cluster rabbit" @$CLUSTER_WITH
	   rabbitmqctl join_cluster rabbit@$CLUSTER_WITH
    else
       echo "rabbitmqctl join_cluster --ram rabbit" @$CLUSTER_WITH
       rabbitmqctl join_cluster --ram rabbit@$CLUSTER_WITH
	fi

    echo "rabbitmqctl start_app"
	rabbitmqctl start_app
	
	echo "rabbitmqctl cluster_status"
	rabbitmqctl cluster_status

    echo "tail -f /var/log/rabbitmq/*.log"
	tail -f /var/log/rabbitmq/*.log
fi
