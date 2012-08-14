#!/bin/sh

echo "Delaying FFMPEG startup"
sleep 30
FFMPEG_SCRIPT="_HOME_/bin/rstream-transcoder -run _DAEMON_ _STREAM_"
exec setuidgid stream $FFMPEG_SCRIPT
sleep 5
