#!/bin/bash

###########################
### Configure Frontend ###
###########################
cd
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash 2> ~/errors.txt
source ~/.bashrc 2> ~/errors.txt
nvm install v12.2.0 2> ~/errors.txt


git clone https://github.com/Pyrd/TodoApp.git 2> ~/errors.txt
cd TodoApp/soar-frontend 2> ~/errors.txt
npm install -g @vue/cli 2> ~/errors.txt
npm install && npm run build 2> ~/errors.txt


#######################
### Configure Nginx ###
#######################


sudo apt-get update 2> ~/errors.txt
sudo apt-get install git nginx -y 2> ~/errors.txt

sudo touch /etc/nginx/sites-available/webapp 2> ~/errors.txt
sudo ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/webapp 2> ~/errors.txt
echo 'server {
    listen      80;
    server_name _;
    root    /home/mathieu_cailly/TodoApp/soar-frontend/dist;
    
    index   index.html index.htm;    # Always serve index.html for any request
    location  / { 
        try_files $uri $uri/ =404;
    }
}' | sudo tee /etc/nginx/sites-available/webapp 2> ~/errors.txt

sudo nginx -t 2> ~/errors.txt
sudo service nginx restart 2> ~/errors.txt