#!/bin/sh
# v0.1
log_user=_USER_
log_dir=_HOME_/var/log/ffmpeg
multilog_bin=/usr/local/bin/multilog
multilog_rotate_size="s10000000";
multilog_rotate_numb="n10";

exec /usr/local/bin/setuidgid $log_user \
	$multilog_bin t \
	$multilog_rotate_size $multilog_rotate_numb \
	$log_dir
