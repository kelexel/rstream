
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
#TRANSCODING            exec /bin/sh -c "_HOME_/bin/rstream-transcoder -run nginx $name";
##TRANSCODING            exec /bin/sh -c "_HOME_/bin/rstream-transcoder -run hls $name";
            allow publish _NGINX_RTMP_IP_;
#PROXYLOCALHOST            deny publish all;
            allow play all;
         }
         application r {
             live on;
#HLS            hls on;
#HLS            hls_path _HLS_PATH_/hls;
#HLS            hls_fragment 5s;
#TRANSCODING            allow publish _FFMPEG_TRANSCODER_IP_;
#TRANSCODING            deny publish all;
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

