RStream 0.5
===========

 *thin as air* Streaming CDN tools

Content
======
* About
	* [What can it do](https://github.com/kelexel/rstream#what-can-it-do)
	* [What it is](https://github.com/kelexel/rstream#what-it-is)
	* [What it is NOT](https://github.com/kelexel/rstream#what-it-is-not)
	* [Why crmptd + nginx-rtmp at the same time ?!](https://github.com/kelexel/rstream#why-crmptd--nginx-rtmp-at-the-same-time-)
	* [Notes on HLS](https://github.com/kelexel/rstream#notes-on-hls)
	* [Notes on Transcoding](https://github.com/kelexel/rstream#notes-on-transcoding)
* Changelog
	* [TAG 0.1](https://github.com/kelexel/rstream#tag-01)
	* [TAG 0.2](https://github.com/kelexel/rstream#tag-02)
	* [TAG 0.3](https://github.com/kelexel/rstream#tag-03)
	* [TAG 0.3t](https://github.com/kelexel/rstream#tag-03t)
	* [TAG 0.5](https://github.com/kelexel/rstream#tag-05)
* [Todo](https://github.com/kelexel/rstream#todo)
* Requirements
	* [Server side requirements](https://github.com/kelexel/rstream#server-side-requirements)
	* [Broadcaster side requirements](https://github.com/kelexel/rstream#broadcaster-side-requirements)
	* [Client side requirements](https://github.com/kelexel/rstream#client-side-requirements)
* [Warnings](https://github.com/kelexel/rstream#warnings)
* Howtos
	* [Howto: Per daemon control](https://github.com/kelexel/rstream#howto-per-daemon-control)
	* [Howto: Ssrver-side tests](https://github.com/kelexel/rstream#howto-server-side-tests)
	* [Howto: Client-side tests](https://github.com/kelexel/rstream#howto-client-side-tests)
	* [Howto: Client-side HLS tests on iOS](https://github.com/kelexel/rstream#howto-client-side-hls-tests-on-ios)
	* [Howto: Transcoding](https://github.com/kelexel/rstream#howto-transcoding)
	* [Howto: Using Wirecast as a broadcaster](https://github.com/kelexel/rstream#howto-using-wirecast-as-a-broadcaster)
* [Credits](https://github.com/kelexel/rstream#credits)
* [Final notes](https://github.com/kelexel/rstream#final-notes)

Preamble
======

What can it do
---

* Setup a fully featured Streaming CDN with HTTPLiveStream + RTMP + Transcoding based on [crtmpdserver](http://www.rtmpd.com/), [nginx-rtmp](https://github.com/arut/nginx-rtmp-module), and [ffmpeg](https://github.com/FFmpeg/FFmpeg)
* (new) Supports multiple transcoding methods (nginx-to-nginx, crtmpd-to-nginx, crtmpd-to-crtmpd) to provide multiple bitrate (240p, 340p, 480p, 720p) streams from one single RTMP feed
* (new) Includes a built-in configuration wizard
* (new) Multi bitrate HLS streams
* Keep all scripts, configs files, recorded media files, HLS-streams to a single chroot-style location (default to ~rstream)
* Uses daemontools to control *all* needed services
* Generates necessary daemontools scripts for crtmpd(/log) nginx(/log) and ffmpeg(/log) transcoders
* Supported broadcasters:
	* [Telestream Wirecast](http://www.adobe.com/products/flash-media-encoder.html) (OSX 10.7.x / Windows 7, h264/aac)
	* [Adobe FlashMediaLiveEncoer](http://www.adobe.com/products/flash-media-encoder.html) (OSX 10.7.x / Windows 7 / Linux, h264/aac)
	* http://www.osmf.org/configurator/fmp/ (Flash Player 11+, h264/aac)
	* [Android: OS Broadcaster](https://play.google.com/store/search?q=+OS+Broadcaster&c=apps) (Android 3+, h264/aac)
* Supported clients:
	* jwplayer
	* flowplayer
	* Mobile Safari (iOS/ipad 5+, iOS/iphone 5+, should work with iOS/ipad 5+)
	* http://dl.dropbox.com/u/2918563/flvplayback.swf (Flash Player 10+)
	* http://www.osmf.org/configurator/fmp/  (Flash Player 10+)

What it is
---

* For me, a week of random r&d including a heavy dose of trial an error, docs ingesting, google resarch, all possible because of [these people](https://github.com/kelexel/rstream#credits)
* It uses good old Bourne shell - so it just works *out of the box* on *any* *NIX
* A set of configuration files and script to simplify deploy a full-feature streaming server CDN capable of transcoding a single FLV (h264/acc no vpx/mp3) received using the RTMP protocol, to multiple bitrate video streams compatible with Adobe FLASH (RTMP) and iOS-style HTTPLiveStreaming (HLS) compatible devices.
* Transcoding has now 3x different ways of working (check Transcoding section), each mode being able to generate 720p, 480p, 340p, 240p FLV (h264/aac) streams from a single given h264/aac stream.
* IF HLS is enabled via nginx, the same broadcaster's stream will be converted to the above four streams + their equivalent in HLS streams, for a total of 8 different streams (4x RTMP and 4x HLS)
* It can now work with crtmpd only, nginx only, or both crtmpd and nginx
* It is per OS customizable - you can easily port rstream to *any* os, assuming you create your own ~/rstream/include/system-os/* files
* It is now multiple-broadcasters-friendly ! (that was a silly limitation in pre 0.5)
* It is now multi-concurent-streams-per-single-broadcaster-friendly ! (assuming you patch crtmpd with the [crtmpd-r779-transparentStream.patch](http://pastebin.com/EmNs2U9M) I wrote)

What it is NOT
---

* It is not pefect, 0.1 was written in roughly 6hours, 0.2 was  released few (sleepless) hours later, and I'm now preparing to push to 0.5 with *major* code refactoring. You should really only use this if you know what you are doing, and mostly, if you are doing on a vanilla server (i.e.: without prior specific config/files/data on it)
* It is NOT-YET production-stress-tested 
* It is NOT-YET Linux-friendly (just fork it!)
* It is NOT-YET OSX-friendly (just fork it!)
* It is NOT-YET capable of steaming vpX/mp3

Why crmptd + nginx-rtmp at the same time ?!
---

The ultimate goal of this is project is to provide an *easy* way for a single Wirecast broadcaster to send one stream to *any* kind of device supporting either the RTMP or HLS protocols.

At the time I'm writing these lines, two great projects exist in the Open-Source RTMP ecosystem (there are many *other* great RTMP servers out there!), crtmpdserver](http://www.rtmpd.com/), and [nginx-rtmp](https://github.com/arut/nginx-rtmp-module).

Each has it's own pros and cons:

On nginx side

* nginx-rtmp has no built-in auth / management modules. It's up to you to write your own returning HTTP codes as allow/deny commands to nginx.
* nginx-rtmp does HLS out of the box, and does it pretty well ! (assuming you compile it with HLS support)
* nginx-rtmp IS BROKEN WITH WIRECAST (the original reason why I created rstream)
* nginx-rtmp is based on nginx (!), and what better than nginx to serve HLS files ?

On crtmpd side

* crtmpd has a built-in auth system
* crtmpd supports RTMP and *many* other protocols
* crtmpd has NO HLS SUPPORT (if you want HLS get the commercial version a.k.a. [evostream](http://www.evostream.com/))
* crmtpd WORKS WITH WIRECAST (!)


This project originally started as a must-need-both crtmpd and nginx, but it quickly evolved to a *jack-of-all-trades* tool to easily deploy either crmpd or nginx-rtmpd or *both* on a *NIX system.

Notes on HLS
---

* HLS is not available in the (free) crtmpd
* HLS is available in nginx-rtmp, no nginx-rtmp = no HLS for you 
* HLS requires ffmpeg
* HLS multi-bitrate is only available if Transcoding is enabled

Notes on Transcoding
---

* ffmpeg is required by rstream-transcoder
* Transcoding only works on nginx for now (as of restream-0.5), but I'm working on it for crtmpd
* rstream-transcoder needs an actual *streamname*, it will not auto-transcode all streams pushed to the rtmpd (-yet-)

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
* added rstream-transcoder -run <method> <stream>
* highly experimental ffmpeg-transcoding using:
	* "~rstream/bin/rstream-transcoder -run m1" == CRTMPD (RTMP / FLV) > ffmpeg > CRTMPD (tcvp / FLV)
	* "~rstream/bin/rstream-transcoder -run m2" == CRTMPD (RTMP / FLV) > ffmpeg > NGINX (rtmp / FLV)
* added "-debug-cycle", cleans, reinstalls, configures and restarts rstream

TAG 0.4
---
* not released, lots of tests and trials, major code refactoring

TAG 0.5
---
* added rstream-config-helper, invoke it on first run
* added nginx startup & control via daemontools 
* added rstream-transcoder -run <method> <stream> -link
* added crtmpd new config files
* added crtmpd transparentStream support in proxypublish
* added nginx new config files
* added massive directory re-structuring

Todo
======

* Make rstream Linux friendly ? (you just fork it!)
* Make rstream in .py or .rb ? (you just fork it!)

Requirements
======

Server side requirements
---

* FreeBSD 9.x - I am currently running this setup inside a FreeBSD 9.1-prelease jail, and it runs great!
* nginx (compiled from a recent port tree, with the "nginx-rtmp" module enabled)
* nginx-rtmp HLS (optional - needs modification of the port's Makefile)
* crtmpd binary distribution, or a custom compiled binary (i.e.: with + r779-transparentStream.patch)
* ffmpeg (optional - if you want transcoding to lower bitrates)
* backup (if any) your previously existing nginx config files located under /usr/local/etc/nginx/* (!!!)

Broadcaster side requirements
---

* The RTMP broadcasting tool of your choice (Wirecast, Flash Media Live Encoder, an flv based RTMP encoder...)

Client side requirements
---

* An RTMP or HLS friendly client
* An RTMP compatible Flash video player of sort

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
(In case you want to install rstream in another location, you only need to edit the HOME variable setting on top of ~rstream/bin/rstream

NOTE: rstream uses *which* to find out if crtmpd/nginx/ffmpeg are installed on your system, and will exit if not found.
In case you want to specify your own location for these binaries, simply edit the top lines in ~/bin/rstream:
```bash
#NGINX_BIN=`which nginx`
NGINX_BIN=/usr/local/sbin/nginx
#CRTMPD_BIN=`which crtmpserver`
CRTMPD_BIN=/my/custom/crtmpserver
#FFMPEG_BIN=`which ffmpeg`
FFMPEG_BIN=/usr/local/sbin/nginx
```

(new 0.5) Start rstream one time to generate a new rstream configuration file
```bash
~rstream/bin/rstream
```
Answer the questions..
If all goes well, rstream will issue a *~rstream/bin/rstream -setup* and generate the appropriate configuration files itself


Howto: Per-daemon control
======

Each daemons (crtmpd, nginx, daemontools) can be controlled via rstream

```bash
# Some shortcut commands..
~rstream/bin/rstream -crtmpd status | stop | start | restart)
~rstream/bin/rstream -nginx (status | stop | start | restart)
~daemontools/bin/rstream -daemontools (status | stop | start | restart)
# control all daemons at once
~daemontools/bin/rstream stop | start | restart

## debug only - WARNING - will start from scratch, deleting all previously created files/dirs/configs !

# deletes all created dir & file structure under ~rstream/ .. take it as a "reset to factory defaults"
~daemontools/bin/rstream -debug-reset
# complete a full cleanup / compile / install cycle ! warning, your configuration files will be re-written !
~daemontools/bin/rstream -debug-cycle
```


Howto: Server-side tests
----

At this point, everything is setup and configured, but no daemons are running.
Here is how to control that everything works as intended to, by starting each daemon one at a time

```bash
# Start nginx
~rstream -nginx test
# Start daemontools
~rstream -daemontools test
# Start crtmpd/run manually at least once using:
~rstream -crtmpd test

# !!! Once you are sure that everything works correctly, you can now link all daemontools-type services to your OS's daemontools service path by using:
~rstream/bin/rstream -link

# finally restart the whole setup
~rstream/bin/rstream start
```

Howto: Client-side tests
---

 I can only recommand the "flvplayer.swf" mentioned [here](https://groups.google.com/forum/?fromgroups#!topic/c-rtmp-server/yPkD3PKnpMM[1-25]) and available for download [here](http://dl.dropbox.com/u/2918563/flvplayback.swf)

* Just download  the file and open it with Flash Player or a Flash Player enabled browser
* Use rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/proxy as "Connecting String" field
* Hit the "Connect" button
* Wait a few seconds (2-3s)
* In the (un-labelled) input field just above the "Connect" button, enter your NGINX_RTMP_STREAM name
* Press the Play button

You should be able to see your stream.

Howto: client-side HLS tests on iOS
---

* Open this URL in Mobile Safari : http://<NGINX_RTMP_FQDN>/hls/<NGINX_RTMP_STREAM>.m3u8

Howto: Transcoding
======

Transcoding for nginx
---

This method will let you transcode one FLV (h264/aac) stream pushed to nginx_rtmp_port:nginx_rtmp_ip/proxy/my_stream to four FLV (h254/aac) streams to nginx_rtmp_port:nginx_rtmp_ip/r/my_stream_<bitrate> (notice the "/r" in the destination, this is the default "app" name used by rstream and accessible to clients)

Run the transcoder using

```bash
# replace "my_stream" by your stream name
~rstream/bin/rstream-transcoder -run nginx my_stream
```

Wait a few seconds...
If nothing happens after more than 10secs, chances are something is wrong with your sources settings, causing ffmpeg to wait until it's connection timeout

If ffmpeg starts transcoding, you can now proceed to client testing.

```bash
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_720
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_480
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_360
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_240
``
Howto: Using Wirecast as a broadcaster
----

Download and install Wirecast(pro) demo from http://www.telestream.net/wirecast/overview.htm

Go to Broadcast settings (on OSX, CMD+Y)
Create a new broadcast profile profile containing:

* Input the matching url (yes the /proxy is required and fixed): rtmp://<CRTMPD_RTMP_IP>:<CRTMPD_RTMP_PORT>/proxy
* Set authentication settings with username "broadcast", password "n3rox". The user list is located in $HOME/etc/crtmpd-users.lua
* Set User Agent to FMLE/3.0
* Set stream name to <CRTMPD_RTMP_STREAM>


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
