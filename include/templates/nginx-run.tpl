#!/bin/sh
nginx=_NGINX_BIN_

exec $nginx -g 'daemon off;' 2>&1
