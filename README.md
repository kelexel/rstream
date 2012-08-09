RStream
===========

Note !!!
Note !!!
Note !!!

* The current release uses and relies on both nginx-rtmp AND c++rtmpserver to provide a streaming CDN allowing ONE UNIQUE broadcaster pushing ONE UNIQUE stream  to *many* RTMP and HLS clients !!!!!!!

About
======

Why crmptd + nginx-rtmp at the same time ?!
---

The ultimate goal of this is project is to provide an *easy* way for a single broadcaster to send one stream to to *any* kinds devices supporting either the RTMP or HLS protocols, this means it can stream to both Flash (+v9?) compatible players AND iOS (v5+) devices

* It assumes you are currently (as of 08/08/2012) using Telestream's Wirecast(pro) which IS NOT YET compatible with nginx-rtmp (see: https://github.com/arut/nginx-rtmp-module/issues/34), thus the need to use crtmpd -s an RTMPD-proxy between the broadcaster (Wireast / FMLE) and nginx-rtmp

What it is
---


* A set of configuration files and script to simplify deploying a full-feature RTMP server capable of transcoding a single FLV (h264) sent over the RTMP protocol,
to multiple bitrate for FLASH-style (RTMP) and iOS-style HTTPLiveStreaming (HLS) compatible browsers.
* If transcoding is enabled the same broadcaster's stream will be transcoded to 3 different sizes 720p, 480p, 320p FLV (h264/aac) over RTMP
* IF NGINX_HLS is enabled the same broadcaster's stream will be converted to -whatever-the-current-resolution-currently-sent-by-the-broadcaster- HLS-friendly url available via the preconfigured nginx-rtmp.conf file

It has been tested using the following broadcasting softwares:

* OSX 10.7.x / Windows 7: Telestream Wirecast (http://www.telestream.net/wirecast/overview.htm)
* OSX 10.7.x / Windows 7 / Linux: Flash Media Live Encoder (http://www.adobe.com/products/flash-media-encoder.html)
* Android: OS Broadcaster (https://play.google.com/store/search?q=+OS+Broadcaster&c=apps)

What it is NOT
---

The -proxy mode is not yet production-stress-tested !!
BUT, assuming nginx-rtmp (and it's HLS properties) have already been stress tested:

* only one connection is made to crtmpd by one single broadcaster 
* crtmpd is only used as a proxy from the broadcaster, pushing  to a *main* nginx-rtmp server
* only nginx is exposed to the clients
* Therefore nginx-rtmp is handle both the connection of the HLS clients (over regular nginx-http), and connections of the RTMP clients (via nginx-rtmp)

It assumes only one broadcaster is currently connected and publishing one unique stream to rtmp://<CRMTPD_RTMP_IP>:<CRTMP_RTMP_PORT>/proxy/<CRTMPD_STREAM> this also means:

* It is NOT MULTI-BROADCASTER friendly !
* It only supports ONE STREAM from the broadcaster 


How it works
---

It uses good old bourne shell - so it just works *out of the box*
Everything is "jailed" to ~rstream EXCEPT the ports required by rstream (see Requirements)
Config files required for rstream are linked from ~rstream/etc/<config_file> to their matching /usr/local/etc/path/to/<config_file>

Todo
======

* Put the transcoding part on github (!)
* Decide if HLS should be done by nginx-rtmp or by ffmpeg -via- crtmpd only
* HLS transcoding (need more nginx-rtmp/hls tests)
* Implement nginx-rtmp only OR crtmpd only option
* Make rstream Linux friendly ? (you just fork it!)
* Make rstream in .py or .rb ? (you just fork it!)

Requirements
======

Server side 
---

* FreeBSD 9.x - I am currently running this setup in FreeBSD 9.1-prelease jail.
* nginx (compiled from a recent port tree, with the "nginx-rtmp" module enabled)
* nginx-rtmp HLS (optional - needs modification of the port's Makefile - see under NGINX_HLS notes)
* ffmpeg (optional - if transcoding to lower bitrates)
* that you backup (if any) your previously existing nginx config files located under /usr/local/etc/nginx/* (!!!)

Broadcaster side
---

* The RTMP broadcasting tool of your choice (Wirecast, Flash Media Live Encoder, an flv based RTMP encoder...)

WARNING
----------

If you have an existing nginx installation please backup your WHOLE NGINX configuration BEFORE running rstream.sh !
More precisely the following files:

* /usr/local/etc/nginx/nginx.conf
* /usr/local/etc/nginx/mime.types (if used in your actual setup)

Installation
======
By default rstream expects to be installed in /home/rstream

Proceed as follows using git:

```bash
mkdir /home/rstream
cd /home/rstream && git clone https://github.com/kelexel/rstream.git
```

Or downloading the current tag

```bash 
mkdir /home/rstream
cd /home/rstream && fetch https://github.com/kelexel/rstream/tarball/<tag>
```

(In case you want to install rstream in another location, you only need to edit the HOME variable setting on top of ~rstream/bin/_installer.sh)

Create a configuration file under ~rstream/etc/rstream.conf (see below)

Configuration
======

To use rstream YOU MUST MANUALY CREATE an ~rstream/etc/rstream.conf file.
Here is a default template:

```bash
### crtmpd related
# You must download the crtmpserver binary from http://www.rtmpd.com/downloads/ and edit the path below
CRTMPD_BIN="$HOME/src/crtmpserver-trunk-x86_64-FreeBSD-9.0/crtmpserver"

# Configuration type (right now only crtmpd-proxy-to-nginx)
CRTMPD_CONF_TYPE="crtmpd-proxy-to-nginx"
CRTMPD_RTMP_IP="1.2.3.4"
CRTMPD_RTMP_PORT="1936"
CRTMPD_LIVEFLV_IP="1.2.3.4"
CRTMPD_LIVEFLV_PORT="21935"
CRTMPD_RTMP_STREAM="test"
# Force crtmpd config file regen
CRTMPD_REGEN_CONF=1

### nginx related
NGINX_RTMP_FQDN="some.fullqualified.domain.name"
NGINX_RTMP_IP="1.2.3.4"
NGINX_RTMP_PORT="1935"
NGINX_RTMP_STREAM="test"
# Force nginx config file regen
NGINX_REGEN_CONF=1

### HLS notes:
# If you want nginx-rtmp/hls support you must edit nginx(-devel)/Makefile and find:
#	CONFIGURE_ARGS+=--add-module=${WRKDIR}/arut-nginx-rtmp-module-${GIT_RTMP_VERSION:S/^0-g//}
# and replace it by:
#	CONFIGURE_ARGS+=--add-module=${WRKDIR}/arut-nginx-rtmp-module-${GIT_RTMP_VERSION:S/^0-g//} \
#	--add-module=${WRKDIR}/arut-nginx-rtmp-module-${GIT_RTMP_VERSION:S/^0-g//}/hls/
# Use HTTP Live Streaming with nginx ? [0/1]
> NGINX_HLS="1"
```

Howto: Wirecast broadcaster to many nginx-rtmp clients (+HLS support)
=====

On server side
-----

```bash
 sh ~rstream/bin/rstream.sh -proxy
```

Make tests!

```bash
#First start nginx
service daemontools star
#Start crtmpd/run manually at least once using:
~rstream/bin/supervise/crtmpd/run
# (should show crtmpd log files and NO ERRORS
#Start crtmpd/log/run manually at least once using:
~rstream/bin/supervise/crtmpd/log/run 
# (should show not output)
```

Once you are sure the service work you can link them to your OS's daemontools service dir using 

```bash
~rstream/bin/rstream.sh -link
service daemontools start
```


On Wirecast broadcaster side
----

Go to Broadcast settings (CMD+Y)
Create a new broadcast profile profile containing:

* Input the matching url (yes the /proxy is required and fixed): rtmp://<CRTMPD_RTMP_IP>:<CRTMPD_RTMP_PORT>/proxy
* Set User Agent to FMLE/3.0
* Set stream name to <CRTMPD_RTMP_STREAM>

On client side
----

Woops I need to make the flv / hls player code :)
BUT 

Testing HLS on iOS devices
---

* Open this URL in Mobile Safari : http://<NGINX_RTMP_FQDN>/hls/<NGINX_RTMP_STREAM>.m3u8

Testing the raw  FLV / RTMP stream
---

 I can only recommand the flvplayer.swf mentioned here: https://groups.google.com/forum/?fromgroups#!topic/c-rtmp-server/yPkD3PKnpMM[1-25] and available for download here: http://dl.dropbox.com/u/2918563/flvplayback.swf

* Just download  the file and open it with flash player or a browser
* Use rtmp://<NGINX_RTMP_IP>:<NGINX_RTMP_PORT>/proxy as "Connecting String" field
* Hit the "Connect" button
* Wait a few seconds (2-3s)
* In the (un-labelled) input field just above the "Connect" button, enter your <NGINX_RTMP_STREAM>
* Press the Play button

Testing the transcoded  FLV / RTMP stream
---

Same as above except you would use as rtmp url:

* rtmp://NGINX_RTMP_IP:<NGINX_RTMP_PORT>/720p
* rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT>/480p
* rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT>/320p


Credits
======

Well, this whole project was a heavy doze of trial an error + docs ingesting + google, but it would have been impossible without these persons / teams:

* Many thanks to arut for his patience and port of nginx-rtmp (available at https://github.com/arut/nginx-rtmp-module)
* Many thanks to the people helping and improving crtmpserver, alias crtmpd, alias c++rtmpserver (available at http://www.rtmpd.com/)
* Many thanks to lobotom.org for the Android testing

Final notes
======

Open-Source 4 ever.
