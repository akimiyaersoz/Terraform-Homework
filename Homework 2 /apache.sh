#!/bin/bash

    apt-get update -y
    apt-get install  apache2 -y 
    echo "Hello world *_*" > /var/www/html/index.html
    systemctl start apache2
    systemctl enable apache2
  
 