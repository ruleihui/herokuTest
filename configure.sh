#!/bin/sh


curl https://rclone.org/install.sh | sudo bash
###
cd /content/
git clone https://github.com/totalleecher/AutoRclone.git
###
cd /content/AutoRclone
pip3 install -r requirements.txt
 
echo "success"


