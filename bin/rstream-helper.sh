#####
### rstream-helper - helper functions for rstream.sh
# 
# license: GPL
# 
# author: rud aka https://github.com/kelexel
#
# url: https://github.com/kelexel/rstream
#
#######

## Used for log consmetics
logHeader(){
	echo "### $1";
}
## Used to check the existence of a given username on the system
checkUser(){
	if [ `id $1 2>&1 | grep -q 'no such user'; echo $?` -eq 0  ]; then 
		echo "*+ adding system user \"$1\" with shell \"/sbin/nologin\" and home \"$HOME\" ";
		pw useradd $1 -s /sbi/nologin -d $2
		if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
	else
		echo "* found system user \"$1\"";
	fi
}
## Used ot check if a given file exists
checkFile(){
	if [ ! -f $1 ] && [ ! -z $2 ]; then echo "!! file \"$1\" not found! exiting"; exit 99; fi
	if [ ! -f $1 ] ; then echo "-! missing file \"$1\" !";
	else echo "* found file \"$1\""; fi
}

## Used to check the existence of a directory, and create it if required
checkDir(){
if [ ! -d $1 ]; then
	if [ ! -z $2 ]; then
		case $2 in
			# -c == create
			"-c") 
				echo "*+ creating \"$1\"";
				mkdir -p $1
				if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
				# check for chown arg
				if [ ! -z $3 ]; then
					echo "*+ setting ownership to \"$3\" on \"$1\""
					chown ${3}:${3} $1
					if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
				fi
				# check chmod chown arg
				if [ ! -z $4 ]; then
					echo "*+ setting permisions to \"$4\" on \"$1\""
					chmod ${4} $1
					if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
				fi
			;;
		esac
	fi
else
	echo "* found $1";
fi
}

## Used to check if a given portname ($1) is installed on the current system
checkPort(){
	if [ ! `pkg_info | grep -q $1 && echo $?` -eq 0 ]; then echo "!! port \"$1\" is not installed on this system ! exiting.": exit 99; fi
	echo "* found port $1";
}

## Used to link configuration file $1 to path $2 (and backups $2 if it is a file)
linkConf(){
	# test if $2 is a file, not a symblink
	if [ ! -h $2 ] && [ -f $2 ]; then
		echo "*+ backuping file \"$1\" to \"${1}.back\"";
		mv $2 ${2}.back
		if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
	fi
	if [ ! -h $2 ]; then
		echo "*+ linking \"$1\" to \"$2\""
		ln -s $1 $2
		if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
	else
		echo "* found existing link from \"$1\" to \"$2\"";
	fi
}

## Used to link a daemontools service
linkService(){
	if [ ! -h $2/$1 ]; then
		echo "*+ creating service link for \"$1\" in \"$2\"";
		ln -s $HOME/bin/supervise/$1 $2/
		if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
	else
		echo "* found daemontools service in $2/$1";
	fi
}

## Used to check if a given port is enabled in the system's rc.conf
enableRc(){
	if [ `grep -q "${1}_enable=\"YES\"" /etc/rc.conf && echo $?` -eq 1 ]; then
		echo "*+ enabling \"$1\" in /etc/rc.conf";
		echo "$1_enable=\"YES\"" >> /etc/rc.conf
		if [ ! $? -eq 0 ]; then echo "!! error !!"; exit 99; fi
	else
		echo "* found $1 enabled in rc.conf";
	fi
}
