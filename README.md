RStream 0.3t
===========

Note !!! Note !!! Note !!!
----

* The current release uses and relies on both nginx-rtmp AND c++rtmpserver to provide a streaming CDN allowing ONE UNIQUE broadcaster pushing ONE UNIQUE stream  to *many* RTMP and HLS clients !!!!!!!

Content
======
* About
	* [What can it do](https://github.com/kelexel/rstream#what-can-it-do)
	* [What it is](https://github.com/kelexel/rstream#what-it-is)
	* [What it is NOT](https://github.com/kelexel/rstream#what-it-is-not)
	* [Why crmptd + nginx-rtmp at the same time ?!](https://github.com/kelexel/rstream#why-crmptd--nginx-rtmp-at-the-same-time-)
* Changelog
	* [TAG 0.1](https://github.com/kelexel/rstream#tag-01)
	* [TAG 0.2](https://github.com/kelexel/rstream#tag-02)
	* [TAG 0.3](https://github.com/kelexel/rstream#tag-03)
	* [TAG 0.3t](https://github.com/kelexel/rstream#tag-03t)
* [Todo](https://github.com/kelexel/rstream#todo)
* Requirements
	* [Server side requirements](https://github.com/kelexel/rstream#server-side-requirements)
	* [Broadcaster side requirements](https://github.com/kelexel/rstream#broadcaster-side-requirements)
	* [Client side requirements](https://github.com/kelexel/rstream#client-side-requirements)
* [Warnings](https://github.com/kelexel/rstream#warnings)
* Configurations
	* [Configuration type "crtmpd-proxy-to-nginx"](https://github.com/kelexel/rstream#configuration-type-crtmpd-proxy-to-nginx)
* Howtos
	* [Howto: Per-daemon control](https://github.com/kelexel/rstream#howto-per-daemon-control)
	* [Howto: Wirecast broadcaster to many nginx-rtmp clients (+HLS support)](https://github.com/kelexel/rstream#howto-wirecast-broadcaster-to-many-nginx-rtmp-clients-hls-support)
	* [Howto: Client side tests](https://github.com/kelexel/rstream#howto-client-side-tests)
	* [NEW 0.3t - Howto: Transcoding, testing *rstream-transcoder -run m1*](https://github.com/kelexel/rstream#howto-wirecast-broadcaster-to-many-nginx-rtmp-clients-hls-support)
* [Credits](https://github.com/kelexel/rstream#credits)
* [Final notes](https://github.com/kelexel/rstream#final-notes)

About
======

What can it do
---

* Setup a fully featured Streaming CDN with HTTPLiveStream + RTMP + Transcoding
* Keep all scripts, configs, media, HLS-stream to to ~rstream
* Copy required config files in place of required daemons, like  ~rstream/etc/<config_file> would match /usr/local/etc/path/to/<config_file>
* Add required daemons to system startup
* Generate daemontools service scripts for crtmpd(/log) and ffmpeg(/log)
* Supported broadcasters:
	* [Telestream Wirecast](http://www.adobe.com/products/flash-media-encoder.html) (OSX 10.7.x / Windows 7, h254/aac)
	* [Adobe FlashMediaLiveEncoer](http://www.adobe.com/products/flash-media-encoder.html) (OSX 10.7.x / Windows 7 / Linux, h254/aac)
	* http://www.osmf.org/configurator/fmp/ (Flash Player 11+, h254/aac)
	* [Android: OS Broadcaster](https://play.google.com/store/search?q=+OS+Broadcaster&c=apps) (Android 3+, h254/aac)
* Supported clients:
	* jwplayer
	* flowplayer
	* Mobile Safari (iOS/ipad 5+, iOS/iphone 5+, should work with iOS/ipad 5+)
	* http://dl.dropbox.com/u/2918563/flvplayback.swf (Flash Player 10+)
	* http://www.osmf.org/configurator/fmp/  (Flash Player 10+)

What it is
---

* For me, a week of random r&d including a heavy dose of trial an error, docs ingesting, google resarch, all possible because of [these people](https://github.com/kelexel/rstream#credits)
* It uses good old bourne shell - so it just works *out of the box*
* A set of configuration files and script to simplify deploy a full-feature streaming server CDN capable of transcoding a single FLV (h264) sent over the RTMP protocol,
to multiple bitrate for FLASH-style (RTMP) and iOS-style HTTPLiveStreaming (HLS) compatible browsers.
* If transcoding is enabled the same broadcaster's stream will be transcoded to 3 different sizes 720p, 480p, 320p FLV (h264/aac) over RTMP
* IF NGINX_HLS is enabled the same broadcaster's stream will be converted to -whatever-the-current-resolution-currently-sent-by-the-broadcaster- HLS-friendly url available via the preconfigured nginx-rtmp.conf file
* new 0.2: it is now per OS-type customisable - but still only supports FreeBSD !

What it is NOT
---

* It is not pefect, 0.1 was written in roughly 6hours, 0.2 was  released few (sleepless) hours later
* The "crtmpd-proxy-to-nginx mode" is not yet production-stress-tested !! (any idea on how to efficiently simul a stress-test is welcomed)
* It is NOT-YET multi-concurent-broadcaster-friendly (just fork it!)
* It is NOT-YET multi-concurent-streams-per-single-broadcaster-friendly (just fork it!)
* It is NOT-YET Linux-friendly (just fork it!)
* It is NOT-YET OSX-friendly (just fork it!)
* It is NOT-YET capable of steaming vp6/mp3

Why crmptd + nginx-rtmp at the same time ?!
---

The ultimate goal of this is project is to provide an *easy* way for a single Wirecast broadcaster to send one stream to *any* kind of device supporting either the RTMP or HLS protocols, this means it can stream to both Flash (+v9+?, +v10+ for sure) compatible players AND iOS (v5+) devices

* Only one connection is made to crtmpd by one single broadcaster 
* crtmpd is only used as a proxy from the broadcaster, pushing  to a *main* nginx-rtmp server
* Only nginx is exposed to the clients
* Therefore nginx handles both the connection of the HLS clients (over regular nginx-http), and connections of the RTMP clients (via nginx-rtmp)

Changelog
======

TAG 0.1
---

* initial release, Freebsd9 only
* added "-proxy"
* added "-debug-reset"

TAG 0.2
---

* updated to new modulable script structure
* added per OS-Type helpers
* created rstream-core containing cross-OS logic
* added nginx-rtmpd-hls.conf-dist
* updated nginx-rtmpd.conf-dist
* removed "-proxy"
* added "-setup crtmpd-proxy-to-nginx"
* added "-nginx (start|stop|status|setup)"
* added "-crtmpd (start|stop|status|setup)"

TAG 0.3
---

* added global "start|stop|restart" switches
* added rstream-firewall.dist 0.1 - Firewalls ONE or SEVERAL IPs on a SINGLE ETHERNET ADAPTER *BSD System !
* enabled auth for broadcasters connecting to rtmp://<CRTMPD_RTMP_IP>:<CRTMPD_RTMP_PORT>/proxy default
* added auth default credentials in $HOME/etc/crtmpd-users.lua (username: "broadcast", password: "n3rox")
* added prerequisists to transcoding

TAG 0.3t
---
* enhancements and fixes for transcoding compatibility
* added ffmpeg source presets in $HOME/etc/ffmpeg 
* highly experimental ffmpeg-transcoding using:
	* *~rstream/bin/rstream-transcoder -run m1* CRTMPD (RTMP / FLV) > ffmpeg > CRTMPD (tcvp / FLV)
	* * ~rstream/bin/rstream-transcoder -run m2* CRTMPD (RTMP / FLV) > ffmpeg > NGINX (rtmp / FLV)
* added "-debug-cycle", cleans, reinstalls, configures and restarts rstream

Todo
======

* Put the transcoding ffmpeg scripts on github (!)
* Decide if HLS should be done by nginx-rtmp or by ffmpeg -via- crtmpd only
* HLS transcoding (need more nginx-rtmp/hls tests)
* Implement nginx-rtmp only OR crtmpd only option
* Make rstream Linux friendly ? (you just fork it!)
* Make rstream in .py or .rb ? (you just fork it!)

Requirements
======

Server side requirements
---

* FreeBSD 9.x - I am currently running this setup in FreeBSD 9.1-prelease jail.
* nginx (compiled from a recent port tree, with the "nginx-rtmp" module enabled)
* nginx-rtmp HLS (optional - needs modification of the port's Makefile - see under NGINX_HLS notes)
* ffmpeg (optional - if transcoding to lower bitrates)
* that you backup (if any) your previously existing nginx config files located under /usr/local/etc/nginx/* (!!!)

Broadcaster side requirements
---

* The RTMP broadcasting tool of your choice (Wirecast, Flash Media Live Encoder, an flv based RTMP encoder...)

Client side requirements
---

* An RTMP or HLS friendly client

WARNINGS
==========

If you have an existing nginx installation please backup your WHOLE NGINX configuration BEFORE running rstream !
More precisely the following files:

* /usr/local/etc/nginx/nginx.conf
* /usr/local/etc/nginx/mime.types (if used in your actual setup)

By using this software you agree to the possibility of breaking something or loosing all your data (j/k).

You understand that *rstream-transcode* is higly experimental and that piping it's output to a log file might be a VERY BAD IDEA.

Installation
======

By default rstream expects to be installed in /home/rstream

Get the rstream-<tag> sources from https://github.com/kelexel/rstream

```bash
# Proceed as follows using git:
mkdir /home/rstream
cd /home/rstream && git clone https://github.com/kelexel/rstream.git

# Or downloading the current tag
mkdir /home/rstream
cd /home/rstream
# fetch a current TAG tarball, ie: fetch -o rstream-<tag>.tgz https://github.com/kelexel/rstream/tarball/<tag>
fetch -o rstream-0.2.tgz https://github.com/kelexel/rstream/tarball/0.2
```

(In case you want to install rstream in another location, you only need to edit the HOME variable setting on top of ~rstream/bin/rstream)

Create a configuration file under ~rstream/etc/rstream.conf (see below)

Configuration type "crtmpd-proxy-to-nginx"
======

To use rstream YOU MUST MANUALY CREATE an ~rstream/etc/rstream.conf file.
Here is the content of a default ~rstream/etc/rstream.conf template for rstream \"crtmpd-proxy-to-nginx\" type (all fields are mendatory):

```bash
### crtmpd related  (used by the broadcaster)
# You must download the crtmpserver binary from http://www.rtmpd.com/downloads/ and edit the path below
CRTMPD_BIN="$HOME/src/crtmpserver-trunk-x86_64-FreeBSD-9.0/crtmpserver"
CRTMPD_RTMP_IP="1.2.3.4"
CRTMPD_RTMP_PORT="1936"
CRTMPD_LIVEFLV_IP="1.2.3.4"
CRTMPD_LIVEFLV_PORT="21935"
CRTMPD_RTMP_STREAM="test"
# Force crtmpd config file regen
CRTMPD_REGEN_CONF=1

### nginx related (used by the clients)
NGINX_RTMP_FQDN="some.fullqualified.domain.name"
NGINX_RTMP_IP="1.2.3.4"
NGINX_RTMP_PORT="1935"
NGINX_RTMP_STREAM="test"
# Force nginx config file regen
NGINX_REGEN_CONF=1
### nginx-rtmp HLS notes:
# If you want nginx-rtmp/hls support you must edit nginx(-devel)/Makefile and find:
#	CONFIGURE_ARGS+=--add-module=${WRKDIR}/arut-nginx-rtmp-module-${GIT_RTMP_VERSION:S/^0-g//}
# and replace it by:
#	CONFIGURE_ARGS+=--add-module=${WRKDIR}/arut-nginx-rtmp-module-${GIT_RTMP_VERSION:S/^0-g//} \
#	--add-module=${WRKDIR}/arut-nginx-rtmp-module-${GIT_RTMP_VERSION:S/^0-g//}/hls/
# Use HTTP Live Streaming with nginx ? [0/1]
> NGINX_HLS="1"

### ffmpeg related (used for transcoding)
# Do we want to activate method1 in rstream-transcode ? 
# Provides:	*~rstream/bin/rstream-transcoder -run m1* CRTMPD (RTMP / FLV) > ffmpeg > CRTMPD (tcvp / FLV)
FFMPEG_CRTMPD_TO_CRTMPD_TRANSCODING="1" # barely working right now
# Do we want to activate method2 in rstream-transcode ? 
# Provides: *~rstream/bin/rstream-transcoder -run m2* CRTMPD (RTMP / FLV) > ffmpeg > NGINX (rtmp / FLV)
FFMPEG_CRTMPD_TO_NGINX_TRANSCODING="1" # barely working right now
# Do we want to activate FFMPEG_CRTMPD_HLS in rstream-transcode ? NO !! (broken right now)
FFMPEG_HLS="0"
```

Howto: Per-daemon control
======

Each daemons (crtmpd, nginx, daemontools) can be controlled via rstream

```bash
# Exemples
~rstream/bin/rstream -crtmpd status
~rstream/bin/rstream -crtmpd stop
~rstream/bin/rstream -crtmpd start
~rstream/bin/rstream -crtmpd restart

~nginx/bin/rstream -crtmpd status
~nginx/bin/rstream -crtmpd stop
~nginx/bin/rstream -crtmpd start
~nginx/bin/rstream -crtmpd restart

~daemontools/bin/rstream -daemontools status
~daemontools/bin/rstream -daemontools stop
~daemontools/bin/rstream -daemontools start
~daemontools/bin/rstream -daemontools restart

```

Howto: Wirecast broadcaster to many nginx-rtmp clients (+HLS support)
======

This will let you setup a Wirecast to *many* (+hls) Streaming CDN

On server side
-----

```bash
~rstream/bin/rstream -setup crtmpd-proxy-to-nginx
```

Make tests!

```bash
# Start nginx
~rstream -nginx start
~rstream -nginx status
# Start daemontools
~rstream -daemontools start
~rstream -daemontools status
# Start crtmpd/run manually at least once using:
~rstream -crtmpd start
~rstream -crtmpd status


# Once you are sure the service work correctly, you can link them to your OS's daemontools service path by using:
~rstream/bin/rstream -link

# finally restart the whole setup
~rstream/bin/rstream restart
```


On Wirecast broadcaster side
----

Download and install Wirecast(pro) demo from http://www.telestream.net/wirecast/overview.htm

Go to Broadcast settings (on OSX, CMD+Y)
Create a new broadcast profile profile containing:

* Input the matching url (yes the /proxy is required and fixed): rtmp://<CRTMPD_RTMP_IP>:<CRTMPD_RTMP_PORT>/proxy
* Set authentication settings with username "broadcast", password "n3rox". The user list is located in $HOME/etc/crtmpd-users.lua
* Set User Agent to FMLE/3.0
* Set stream name to <CRTMPD_RTMP_STREAM>

On client side
----

See [Howto: Client side tests](https://github.com/kelexel/rstream#howto-client-side-tests)


Howto: client side tests
======

Woops I need to make the flv / hls player code :)
BUT 

Testing HLS on iOS devices
---

* Open this URL in Mobile Safari : http://<NGINX_RTMP_FQDN>/hls/<NGINX_RTMP_STREAM>.m3u8

Testing the raw  FLV / RTMP stream
---

 I can only recommand the "flvplayer.swf" mentioned [here](https://groups.google.com/forum/?fromgroups#!topic/c-rtmp-server/yPkD3PKnpMM[1-25]) and available for download [here](http://dl.dropbox.com/u/2918563/flvplayback.swf)

* Just download  the file and open it with flash player or a browser
* Use rtmp://<NGINX_RTMP_IP>:<NGINX_RTMP_PORT>/proxy as "Connecting String" field
* Hit the "Connect" button
* Wait a few seconds (2-3s)
* In the (un-labelled) input field just above the "Connect" button, enter your <NGINX_RTMP_STREAM>
* Press the Play button

Howto: Transcoding, testing "~rstream/bin/stream-transcoder -run m1"
======

*working* - Testing the transcoded  FLV / RTMP streams on CRTMPD (as a broadcaster)
---

* As a broadcaster log to crtmpd *rtmp://<CRTMPD_RTMP_IP>:<CRTMPD_RTMP_PORT>/proxy*  supplying your <CRTMPD_RTMP_STREAM> and credentials
* As a non-privileged user (preferably \"$USER\"), *run ~rstream/bin/rstream-transcoder -run m1* WARNING do not pipe this command to a (log)file !
* As a client, open any of the following URLs:
	* rtmp://<CRTMPD_RTMP_IP:<CRTMPD_RTMP_PORT>/720p/<CRTMPD_RTMP_STREAM>
	* rtmp://<CRTMPD_RTMP_IP:<CRTMPD_RTMP_PORT>/480p/<CRTMPD_RTMP_STREAM>
	* rtmp://<CRTMPD_RTMP_IP:<CRTMPD_RTMP_PORT>/320p/<CRTMPD_RTMP_STREAM>


*broken* - Testing the transcoded  FLV / RTMP stream
---

Same as above except you would use as rtmp url:

* rtmp://NGINX_RTMP_IP:<NGINX_RTMP_PORT>/720p
* rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT>/480p
* rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT>/320p


Credits
======


I would like to extend my *diamonds for ever* to these persons / teams:

* arut, for his patience and port of nginx-rtmp (available at https://github.com/arut/nginx-rtmp-module)
* the people helping and improving crtmpserver, alias crtmpd, alias c++rtmpserver (available at http://www.rtmpd.com/)
* whoever created and shared http://dl.dropbox.com/u/2918563/flvplayback.swf
* whoever created and shared http://www.osmf.org/configurator/fmp/
* lobotom(.org), for the Android testing
* #nginx@freenode
* #freebsd@freenode
* #ffmpeg@freenode
* #mootools@freenode
* #monome@freenode

Final notes
======

Open-Source 4 ever.
