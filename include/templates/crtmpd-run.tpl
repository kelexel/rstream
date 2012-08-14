#!/bin/sh
# v0.2
crtmpd_bin="_CRTMPD_BIN_"
crtmpd_config="_CRTMPD_CONF_"
crtmpd_user="_USER_"

exec /usr/local/bin/setuidgid $crtmpd_user $crtmpd_bin $crtmpd_debug $crtmpd_config && sleep 60
