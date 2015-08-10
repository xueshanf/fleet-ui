
## Changes 
* Use wss:// protocol for /ws/journal/<unit> API path, instead of ws: protocol because we need to run Nginx basic auth through SSL. 
* Disable 'New Unit' function. New units should be submitted by CI/CD system.
* Put a workaround to have a longer fleeetctl status pulling interval.
* Change web color theme.
* Use Debian jessie base image to match the "fleet-ui-builder" Golang image to avoid dynamically linked library problems.

## To build

This repo image is built using [Xu Wang's fleet-ui docker builder](https://github.com/xuwang/docker-fleetui-builder).
```
$ git clone https://github.com/xuwang/docker-fleetui-builder.git
$ cd /docker-fleetui-builder
$ ./build.sh github.com/xueshanf/fleet-ui
```

## Configure basic auth with nginx for fleet-ui, running beind AWS ELB

Reference:  [Websocket with ELB](http://blog.flux7.com/web-apps-websockets-with-aws-elastic-load-balancing)

### Load balancer

Load balancer should use TCP protocal (not HTTPS), port 443. Instance port is 8083.

Reference:  [Websocket with ELB](http://blog.flux7.com/web-apps-websockets-with-aws-elastic-load-balancing)

####  Nginx with websocket configuration

Terminate SSL on Nginx, not on ELB. 

Reference:[Websocket Nginx](http://nginx.com/blog/websocket-nginx/)

```
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
    server_name <fqdn>;

    # Use websocket. Should not termiate SSL at ELB.
    listen 8083 ssl;

    ssl on;
    # Self-signed cert is okay
    ssl_certificate /etc/nginx/certs/fleetui.crt;
    ssl_certificate_key /etc/nginx/certs/fleetui.key;
    
    ...
    location / {
        auth_basic            "Restricted";
        auth_basic_user_file  /etc/nginx/certs/fleetui.htpasswd;
        proxy_pass http://fleetui;
    }

    location /ws/ {
        proxy_pass http://fleetui;
        proxy_read_timeout 999999999;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
    }

    location /_ping {
        auth_basic off;
        proxy_pass http://fleetui;
    }
}
```
