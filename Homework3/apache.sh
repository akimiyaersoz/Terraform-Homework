#!/bin/bash

sudo apt update
sudo apt install apache2 -y
sudo apt systemctl start apache2
sudo apt systemctl enable apache2