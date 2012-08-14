
user  www;
worker_processes  1;

# required by daemontools, but already passed by the run script
# daemon off;

error_log stderr;

events {
    worker_connections  1024;
}


rtmp {
   server {
        listen _NGINX_RTMP_IP_:_NGINX_RTMP_PORT_;
            chunk_size 128;
            publish_time_fix on;
            application proxy {  
            live on;
            # Not working on FreeBSD as of 08/08/2012
            # exec /usr/local/etc/nginx/nginx_rtmp_transcode.sh;
            # exec /usr/local/bin/ffmpeg -re -i rtmp://_NGINX_RTMP_FQDN_:_NGINX_RTMP_PORT_/proxy/_NGINX_RTMP_STREAM_ -vcodec flv -acodec copy -s 32x32 -f flv rtmp://_NGINX_RTMP_FQDN_:_NGINX_RTMP_PORT_/720p/_NGINX_RTMP_STREAM_;
            # exec /home/stream/tmp/test.sh;
            allow publish _NGINX_RTMP_IP_;
            deny publish all;
            allow play all;
         }
         application r {
             live on;
#HLS            hls on;
#HLS            hls_path _HLS_PATH_/hls;
#HLS            hls_fragment 5s;
#TRANSCODING             allow publish _FFMPEG_TRANSCODER_IP_;
            deny publish all;
            allow play all;
        }
    }
}

http {
    include _HOME_/etc/nginx-rtmp-mime.types;
    server {
        listen _NGINX_RTMP_IP_:80;
        location / {
            root _HLS_WWW_;
        }
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
        location /stat.xsl {
            root _HLS_WWW_/stats/;
        }
#HLS        location /hls {
#HLS            root _HLS_PATH_;
#HLS        }
    }
}

