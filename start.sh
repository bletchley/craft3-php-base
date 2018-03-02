#!/bin/bash

env | awk -F = '{print $1}'

if (( $EUID != 0 )); then
    user=`whoami`
    group=`id -gn`

    # Update to actual username of running user
    sed -i -e "s/user  nginx/user  $user/" /etc/nginx/nginx.conf
    sed -i -e "s/user = nginx/user = $user/" /etc/php/7.1/fpm/pool.d/www.conf
    sed -i -e "s/listen.owner = nginx/listen.owner = $user/" /etc/php/7.1/fpm/pool.d/www.conf
    sed -i -e "s/group = nginx/group = $group/" /etc/php/7.1/fpm/pool.d/www.conf
    sed -i -e "s/listen.group = nginx/listen.group = $group/" /etc/php/7.1/fpm/pool.d/www.conf
fi

# Set the correct port for nginx
sed -i -e "s/DOCKER_PORT/$PORT/" /etc/nginx/conf.d/default.conf

# Update nginx to match worker_processes to no. of cpu's
sed -i -e "s/worker_processes  1/worker_processes $NGINX_WORKERS/" /etc/nginx/nginx.conf

# Start supervisord and services
/usr/local/bin/supervisord -n -c /etc/supervisord.conf