#!/bin/sh
#####
### rstream - FreeBSD 9.x RTMP (+HTTPLiveStream +Transcoding) deployment tool 
# 
# license: GPL
# 
# authors:
# - rud aka https://github.com/kelexel
# 
#
# you might want to change the following

# The root directory where everything will be set
HOME="/home/rstream"
# User to which everything will be setuidgid to
# This only checks & creates the default user test on your system
USER="rstream"


#########################
#########################
#########################
# You should not need to edit anything below this point.
# If you have/feel the need to do otherwise, please inform me of your changes via github.
#########################
#########################
#########################


####
### System checks
####
# include all the helper functions, ABSOLUTELY required
if [ ! -f $HOME/bin/rstream-helper.sh ]; then echo "!! invalid rstream setup - invalid HOME"; exit 99; fi
. $HOME/bin/rstream-helper.sh


init(){
logHeader "- init checks"
# check for config file
checkFile $HOME/etc/rstream.conf 1


# check if our main $USER exists
checkUser $USER $HOME;
# check $HOME strucutre
checkDir $HOME/var/log -c
checkDir $HOME/var/log/www -c
checkDir $HOME/var/log/crtmpd -c $USER
checkDir $HOME/var/log/nginx -c
checkDir $HOME/var/log/nginx-crtmpd-ffmpeg -c $USER
checkDir $HOME/shared/media -c $USER
checkDir $HOME/shared/www -c $USER 755
checkDir $HOME/tmp -c

# set daemontools_services based on default port service path
daemontools_services="/var/service"

if [ ! -z $NGINX_HLS ] && [ $NGINX_HLS -eq 1 ]; then checkDir $HOME/tmp/hls -c www 777; fi
}

####
### Daemon tools
####
setupDaemontools(){
	logHeader "- daemontools"
	# check if daemontools is installed
	checkPort "daemontools"
	# check if services exist
	checkDir $daemontools_services -rc
	# enable daemontools
	enableRc "svscan"
}

####
### Nginx checks
####
setupNginx(){
	logHeader "- nginx"
	# test if nginx is installed
	checkPort "nginx"
	nginx_bin=`which nginx` # should result in /usr/local/bin/nginx
	# test if nginx was compiled with nginx-rtmp support
	if [ ! `$nginx_bin -V 2>&1 | grep -q rtmp &&  echo $?` -eq 0 ]; then echo "!! nginx was not compiled with nginx-rtmp support ! exiting."; exit 99; fi
	echo "* found nginx-rtmp support";
	# test if nginx was compiled with nginx-rtmp/hls support
	if [ $NGINX_HLS -eq 1 ] && [ ! `$nginx_bin -V 2>&1 | grep -q hls &&  echo $?` -eq 0 ]; then echo "!! nginx was not compiled with nginx-rtmp/hls support ! exiting."; exit 99; 
		else if [ $NGINX_HLS -eq 1 ]; then echo "* found nginx-rtmp/hls support"; fi
	fi
	# set nginx_conf to default FreeBSD nginx port config location
	nginx_conf="/usr/local/etc/nginx/nginx.conf"
	
	if [ $NGINX_REGEN_CONF -eq 1 ]; then echo "-! enforcing NGINX_REGEN_CONF"; fi
	if [ $NGINX_REGEN_CONF -eq 1 ] || [ ! -f $HOME/etc/nginx-rtmp.conf ]; then
		echo "*+ generating new nginx conf";
		# generate local nginx conf
		cat $HOME/etc/nginx-rtmp.conf-dist \
			| sed s,_HOME_,$HOME,g \
			| sed s,_NGINX_RTMP_IP_,$NGINX_RTMP_IP,g \
			| sed s,_NGINX_RTMP_PORT_,$NGINX_RTMP_PORT,g \
			| sed s,_NGINX_RTMP_STREAM_,$NGINX_RTMP_STREAM,g \
			> $HOME/etc/nginx-rtmp.conf
	fi
	# link nginx conf
	linkConf $HOME/etc/nginx-rtmp.conf $nginx_conf
	# only make the following tests if NGINX_HLS is set to 1
	if [ $USER_HLS ]; then
		# set nginx_mime_types to default FreeBSD nginx port config location
		nginx_mime_types="/usr/local/etc/nginx/mime.types"
		# link mime types
		linkConf $HOME/etc/nginx-rtmp-mime.types $nginx_mime_types
	fi
	# enable nginx
	enableRc "nginx"
}	

####
### CRTMPD Server
####
setupCrtmpd(){
	logHeader "- crtmpd"
	# check if CRTMPD_BIN is found
	checkFile $CRTMPD_BIN 1
	#set CRTMPD_CONF variable based on $CRTMPD_CONF_TYPE
	if [ ! -f $HOME/etc/${CRTMPD_CONF_TYPE}.lua ]; then echo "!! Invalid CRTMPD_CONF_TYPE ! exiting. "; exit 99; fi
	CRTMPD_CONF="$HOME/etc/${CRTMPD_CONF_TYPE}.lua"
	# cosmetics
	if [ $CRTMPD_REGEN_CONF -eq 1 ]; then echo "-! enforcing CRTMPD_REGEN_CONF"; fi
	# generate CRTMPD CONF
	if [ $CRTMPD_REGEN_CONF -eq 1 ] || [ ! -f $HOME/etc/crtmpd-proxy-to-nginx.lua ]; then
		echo "*+ generating new crtmpd conf";
		# generate local nginx conf
		cat ${CRTMPD_CONF}-dist \
			| sed s,_HOME_,$HOME,g \
			| sed s,_NGINX_RTMP_IP_,$NGINX_RTMP_IP,g \
			| sed s,_NGINX_RTMP_PORT_,$NGINX_RTMP_PORT,g \
			| sed s,_NGINX_RTMP_STREAM_,$NGINX_RTMP_STREAM,g \
			| sed s,_CRTMPD_RTMP_IP_,$CRTMPD_RTMP_IP,g \
			| sed s,_CRTMPD_RTMP_PORT_,$CRTMPD_RTMP_PORT,g \
			| sed s,_CRTMPD_LIVEFLV_IP_,$CRTMPD_LIVEFLV_IP,g \
			| sed s,_CRTMPD_LIVEFLV_PORT_,$CRTMPD_LIVEFLV_PORT,g \
			| sed s,_CRTMPD_RTMP_STREAM_,$CRTMPD_RTMP_STREAM,g \
			> $CRTMPD_CONF
	fi


	# generate CRTMPD run script
	#if [ $CRTMPD_REGEN_CONF -eq 1 ]; then echo "-! enforcing regen_conf"; fi
		# generate crtmpd/run script
		echo "*+ generating new crtmpd/run script";
		cat $HOME/bin/supervise/crtmpd/run-dist \
			| sed s,_CRTMPD_BIN_,$CRTMPD_BIN,g \
			| sed s,_CRTMPD_CONF_,$CRTMPD_CONF,g \
			| sed s,_USER_,$USER,g \
			> $HOME/bin/supervise/crtmpd/run
			chmod 755 $HOME/bin/supervise/crtmpd/run
		# generate crtmpd/log/run script
		echo "*+ generating new crtmpd/log/run script";
		cat $HOME/bin/supervise/crtmpd/log/run-dist \
			| sed s,_USER_,$USER,g \
			| sed s,_LOG_DIR_,$HOME/var/log/crtmpd,g \
			> $HOME/bin/supervise/crtmpd/log/run
			chmod 755 $HOME/bin/supervise/crtmpd/log/run

	#fi
}

####
### Services
####
setupServices(){
	logHeader "- services"
	if [ -z $daemontools_services ] || [ ! -d $daemontools_services ]; then echo "!! error invalid daemontools_services \"$daemontools_services\"! exiting."; exit 99; fi
	# testing if link to crtmpd service exists
	linkService crtmpd $daemontools_services
}

debugReset(){
	rm -rf $HOME/tmp
	rm -rf $HOME/var
	rm -rf $HOME/shared

	#rm -f $HOME/etc/rstream.conf
	rm -f $HOME/etc/crtmpd-proxy-to-nginx.lua
	rm -f $HOME/etc/nginx-rtmp.conf

	rm -f $HOME/bin/supervise/crtmpd/run
	rm -f $HOME/bin/supervise/crtmpd/log/run
}

case $1 in
	-proxy)
		. $HOME/etc/rstream.conf
		init
		setupDaemontools
		setupNginx
		setupCrtmpd
	;;
	-link)
		init
		setupServices
	;;
	-debug-reset)
		debugReset
	;;
	*)
		echo "!! error, no valid argument(s) specified !"
		echo "-! please consult the documentation: https://github.com/kelexel/rstream";
		exit 1
	;;
esac




# nice and clean ..
exit 0;



