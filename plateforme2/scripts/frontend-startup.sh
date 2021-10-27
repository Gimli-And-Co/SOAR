#!/bin/bash
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get update
sudo apt-get install git nginx nodejs -y

### Configure Nginx
sudo touch /etc/nginx/sites-available/webapp
sudo ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/webapp
# sudo vim /etc/nginx/sites-available/vue_project
echo 'server {
    listen      80;
    server_name example.com;    charset utf-8;
    root    {{app_root}}/dist;
    index   index.html index.htm;    # Always serve index.html for any request
    location / {
        root {{app_root}}/dist;
        try_files $uri /index.html;
    }    error_log  /var/log/nginx/vue-app-error.log;
    access_log /var/log/nginx/vue-app-access.log;
}' | sudo tee /etc/nginx/sites-available/webapp

cd 
sudo git clone https://github.com/Pyrd/TodoApp.git
cd TodoApp/soar-frontend
npm install && npm run build
cp -r dist/  /


sudo nginx -t
sudo service nginx restart
# sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Avenue Code is the leading software consulting agency focused on delivering end-to-end development solutions for digital transformation across every vertical. We pride ourselves on our technical acumen, our collaborative problem-solving ability, and the warm professionalism of our teams.!</h1></body></html>' | sudo tee /var/www/html/index.html"