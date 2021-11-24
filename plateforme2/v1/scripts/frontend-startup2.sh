#!/bin/sh
sudo echo Script started > /tmp/script.log

FILE="/tmp/index.html"
sudo /bin/cat <<EOF >$FILE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head><title>Here you are Papy</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><style>
.videoWrapper { position: absolute;top: 0;left: 0;width: 100%;height: 100%;background-image: linear-gradient(to top, #86377b 20%, #27273c 80%);}
.videoWrapper iframe {  top: 10;left: 50;width: 100%;height: 100%;}
.centered {position: absolute;top: 10%;left: 35%;}</style>
</head>
<body>
<div class="videoWrapper">
<div class="centered"><H1 style="color:#D83623;font-family: Impact, Charcoal, sans-serif;text-shadow: 1px 2px #FFFFF;">Welcome to The <b> Azure Loco Party :D !!!</b></h1> </div>
<iframe src="https://player.vimeo.com/video/343579787?autoplay=1&color=ff0179&title=0&byline=0&portrait=0" width="1024" height="768" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>
</div>
</body>
</html>
EOF

sudo apt  --assume-yes install nginx
sudo ufw allow 'Nginx HTTP'
#sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
# sudo cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index.original.html  
sudo cat $FILE > /var/www/html/index.html