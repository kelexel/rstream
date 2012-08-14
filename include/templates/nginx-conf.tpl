
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
#TRANSCODING            exec /usr/local/bin/ffmpeg -threads 15 -i rtmp://_NGINX_RTMP_IP_:_NGINX_RTMP_PORT_/proxy/${name} -re -acodec libfaac -ar 44100 -b:a 96k -vcodec libx264 -s 1280x720 -b:v 500k -metadata streamName=${name}_720p -f flv rtmp://_NGINX_RTMP_IP_:_NGINX_RTMP_PORT_/r/${name}_720p -re -acodec libfaac -ar 44100 -b:a 96k -vcodec libx264 -s 854x480 -b:v 500k -metadata streamName=${name}_720p -f flv rtmp://_NGINX_RTMP_IP_:_NGINX_RTMP_PORT_/r/${name}_480p -re -acodec libfaac -ar 22050 -b:a 96k -vcodec libx264 -s 640x360 -b:v 300k -metadata streamName=${name}_720p -f flv rtmp://_NGINX_RTMP_IP_:_NGINX_RTMP_PORT_/r/${name}_360p -re -acodec libfaac -ar 22050 -b:a 48k -vcodec libx264 -s 426x250 -b:v 100k -metadata streamName=${name}_720p -f flv rtmp://_NGINX_RTMP_IP_:_NGINX_RTMP_PORT_/r/${name}_240p;
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

