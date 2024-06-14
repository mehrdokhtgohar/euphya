#!/bin/bash

# app configuration
export URL=0.0.0.0
export PORT=8080

# Define your domain and email for Certbot
DOMAIN="euphya.co"
EMAIL="mehrdokht.gohard@gmail.com"

# Update and install required packages
sudo apt update
sudo apt install -y npm nginx certbot python3-certbot-nginx

# Install pm2 globally
sudo npm install -g pm2

# Install app dependencies
sudo npm install package.json

# Ensure pm2 is set to start on system boot
pm2 startup systemd -u $USER --hp $HOME

# Restart the application with pm2
pm2 delete all
pm2 start --name 'euphya' server.js
pm2 save

# NGINX configuration
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    # Redirect HTTP to HTTPS
    location / {
        return 301 https://$DOMAIN$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://$URL:$PORT; # Adjust the port if necessary
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable the new configuration by creating a symbolic link
if [ ! -L /etc/nginx/sites-enabled/$DOMAIN ]; then
    sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
fi

# Test and reload NGINX configuration
sudo nginx -t
sudo systemctl reload nginx

# Obtain SSL certificate using Certbot if it doesn't already exist
if ! sudo certbot certificates | grep -q "Domains: $DOMAIN"; then
    sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN
else
    # If certificate exists, ensure renewal configuration is updated
    sudo certbot renew --nginx
fi

# Set up auto-renewal for Certbot
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Restart services to ensure they are running with the new configuration
sudo systemctl restart nginx
pm2 restart all

echo "Setup complete."
