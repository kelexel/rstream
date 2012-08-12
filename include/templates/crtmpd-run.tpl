#!/bin/sh
# v0.1
crtmpd_bin="_CRTMPD_BIN_"
crtmpd_config="_CRTMPD_CONF_"
crtmpd_user="_USER_"

#$crtmpd_bin  --uid=$crtmpd_user --gid=$crtmpd_user --use-implicit-console-appender $crtmpd_config
$crtmpd_bin  --uid=$crtmpd_user --gid=$crtmpd_user $crtmpd_config

sleep 300