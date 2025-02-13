#! /bin/bash
sudu su
sudo yum update -y
sudo docker run -it mysql 
export ENDPOINT=$1
sudo usermod -aG docker $USER
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock
sudo service docker start

sudo docker run -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:8.0 --name=dbcontainer

sudo docker exec -it dbcontainer mysql -upetclinic -ppetclinic -h ${ENDPOINT} -e "create database petclinic"

#sudo docker run -itd -p 8080:8080 shivanishivani/clinic09:latest
sudo docker run -itd -p 8080:8080 -e MYSQL_URL=jdbc:mysql://${ENDPOINT}/petclinic shivanishivani/clinic09:latest

