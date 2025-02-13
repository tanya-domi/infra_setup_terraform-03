#! /bin/bash

sudu su
sudo yum update -y

cd
touch hello.txt

sudo systemctl start docker


sudo docker run -itd -e MYSQL_USER=${MYSQL_USERNAME} -e MYSQL_PASSWORD=${MYSQL_PASSWORD} -e MYSQL_ROOT_PASSWORD=${ROOT_PASSWORD} -e MYSQL_DATABASE=petclinic --name=dbcontainer -p 3306:3306 mysql:8.0 

sudo docker exec -itd dbcontainer mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -h ${ENDPOINT} -e "create database petclinic"

sudo docker run -itd -p 8080:8080 -e MYSQL_URL=jdbc:mysql://${ENDPOINT}/petclinic shivanishivani/clinic09:latest