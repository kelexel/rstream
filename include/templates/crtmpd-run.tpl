#!/bin/sh
# v0.2
crtmpd_bin="_CRTMPD_BIN_"
crtmpd_config="_CRTMPD_CONF_"
crtmpd_user="_USER_"
#crtmpd_debug="--use-implicit-console-appender"

# Does not work with daemontools, but might with other startup-scripts
#$crtmpd_bin  $crtmpd_debug --uid=$crtmpd_user --gid=$crtmpd_user $crtmpd_config

# works with daemontools
exec /usr/local/bin/setuidgid $crtmpd_user $crtmpd_bin $crtmpd_debug $crtmpd_config

sleep 60