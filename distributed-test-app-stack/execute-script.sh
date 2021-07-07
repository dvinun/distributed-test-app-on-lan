# make sure the docker compose is installed
# 1. create a file 'docker-compose' in /usr/bin path. new file path: /usr/bin/docker-compose
sudo vi /usr/bin/docker-compose

# bof
#/bin/bash
docker run \
  -ti --rm \
  -v $(pwd):$(pwd) \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w $(pwd) \
  docker/compose \
  $@
# eof

# close file without saving changes - :q!
# close file saving changes - :wq!

# 2. give read-write permissions
sudo chmod +x /usr/bin/docker-compose

# on linux machine using putty: remove old folder and create new one
cd /home
sudo rm -rf distributed-test-app-stack
sudo mkdir distributed-test-app-stack
sudo chmod ugo+rw distributed-test-app-stack/

# on windows machine using command prompt using pscp.exe: copy over all the files to linux from windows
cd C:\Vinu\Projects\Personal\distributed-test-app-on-lan\tools
pscp.exe -P 22 -r C:\Vinu\Projects\Personal\distributed-test-app-on-lan\distributed-test-app-stack\ vinayaka.amaresh@10.0.40.21:/home/distributed-test-app-stack

# on linux machine: give read-write permissions to distributed-test-app-stack folder so the stack commands can be run
cd /home
sudo chmod -R 755 distributed-test-app-stack

# before running the stack command, create private registry
sudo docker service rm registry
sudo docker service create --name registry --publish published=5000,target=5000 registry:2
sudo docker service ls
 
# on linux machine using putty: run the stack to install the stack
cd 
cd /home/distributed-test-app-stack/
./deploy-test-app-stack.sh "vm-ubuntu-dev" "distributed-test-app-stack_redis-sentinel" "vm-ubuntu-dev"  "distributed-test-app-stack_redis-master" "ubuntu-dev-01" "distributed-test-app-stack_redis-slave1" "ubuntu-dev-02"  "distributed-test-app-stack_redis-slave2" "vm-ubuntu-dev" "distributed-test-app-stack_rabbit-mq1" "ubuntu-dev-01" "distributed-test-app-stack_rabbit-mq2" "ubuntu-dev-02" "distributed-test-app-stack_rabbit-mq3" 


# test nginx separately
cd 
cd /home/distributed-test-app-stack/
sudo docker stack deploy -c docker-compose-stack-nginx-test.yml nginx-test-stack

sudo docker-compose -f docker-compose-stack-nginx-test.yml up

# to test the python app, following are the commands...
docker-compose -f test-app-py/compose-app.yml build
docker-compose -f test-app-py/compose-app.yml push
docker service create --name test-app-svc --replicas 3 -p 38000:611 127.0.0.1:5000/test-app-py

# to test setup rabbit mq manually 
cd 
cd /home/distributed-test-app-stack/rabbitmq
sudo docker-compose -f rabbitmq-docker-compose.yml up

# optionally do this to run in interactive mode (didnt work)
cd 
cd /home/distributed-test-app-stack/rabbitmq
sudo docker-compose -f rabbitmq-docker-compose.yml run --rm rabbit-mq

# remove redis stack and everything 
sudo docker container prune -f
sudo docker service rm registry
sudo docker stack rm distributed-test-app-stack
# sudo docker stack rm nginx-test-stack
sudo docker system prune -a -f
sudo docker network prune -f
sudo docker rmi $(sudo docker images -a -q) -f
sudo docker volume prune -f
sudo docker image prune -f
sudo docker service rm registry


# log into the container 
 sudo docker exec -it redis-stack_rabbit-mq1.9fo635zlap7s7sor3bx62vtfg.9tf1g3wjdjkddevq53po4zrzk /bin/sh
 
# list environment variables in the container
printenv

