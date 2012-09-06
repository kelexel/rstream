RStream 0.6
===========

 *thin as air* Streaming CDN toolkit

Content
======
* Preamble
	* [What can it do](https://github.com/kelexel/rstream#what-can-it-do)
	* [What it is](https://github.com/kelexel/rstream#what-it-is)
	* [What it is NOT](https://github.com/kelexel/rstream#what-it-is-not)
	* [Why crmptd + nginx-rtmp at the same time ?!](https://github.com/kelexel/rstream#why-crmptd--nginx-rtmp-at-the-same-time-)
	* [Notes on crtmpd](https://github.com/kelexel/rstream#Notes-on-crtmpd)
	* [Notes on nginx-rtmp](https://github.com/kelexel/rstream#Notes-on-nginx-rtmp)
	* [Notes on HLS](https://github.com/kelexel/rstream#notes-on-hls)
	* [Notes on Transcoding](https://github.com/kelexel/rstream#notes-on-transcoding)
* Changelog
	See CHANGELOG
* [Todo](https://github.com/kelexel/rstream#todo)
* Requirements
	* [Server side requirements](https://github.com/kelexel/rstream#server-side-requirements)
	* [Broadcaster side requirements](https://github.com/kelexel/rstream#broadcaster-side-requirements)
	* [Client side requirements](https://github.com/kelexel/rstream#client-side-requirements)
* [Disclaimer](https://github.com/kelexel/rstream#displaimer)
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

Setup a fully featured Streaming CDN with HTTPLiveStream + RTMP + Transcoding based on [crtmpdserver](http://www.rtmpd.com/), [nginx-rtmp](https://github.com/arut/nginx-rtmp-module), and [ffmpeg](https://github.com/FFmpeg/FFmpeg):

* Let you configure already installed crtmpd, ffmpeg, or BOTH (for proxy mode !)
* Sandboxes all components (temporary files, HLS streams, config files, log files ...)
* Create nginx-rtmp config files
* Create crtmpd conf files
* Generates necessary daemontools scripts for crtmpd(/log) nginx(/log) and ffmpeg(/log) 
* Provide in depth control of each daemontools scripts via the *~rstream* helper
* Make requirements checks (for HLS and FFMPEG notably)
* Provide a wrapper to ffmpeg via *rstream-transcoder* to generate multiple bitrate (240p, 340p, 480p, 720p) streams from one single RTMP feed
* Provide HLS (HTTP Live Streaming) via ffmpeg and nginx-rtmp (Read HLS notes !)
* (new) Supports multiple transcoding methods (nginx-to-nginx, crtmpd-to-crtmpd) to provide multiple bitrate (240p, 340p, 480p, 720p) streams from one single RTMP feed
* (new) Built-in configuration wizard
* (new) Multi bitrate HLS streams (via nginx-rtmp & ffmpeg)
* (experimental) HLS via *ffmpeg onnly*, can connect to either crtmpd or nginx (*~rstream-transcoder -run hls stream_name*)
* Support the following broadcasters:
	* [Telestream Wirecast](http://www.adobe.com/products/flash-media-encoder.html) (OSX 10.7.x / Windows 7, h264/aac)
	* [Adobe FlashMediaLiveEncoer](http://www.adobe.com/products/flash-media-encoder.html) (OSX 10.7.x / Windows 7 / Linux, h264/aac)
	* http://www.osmf.org/configurator/fmp/ (Flash Player 11+, h264/aac)
	* [Android: OS Broadcaster](https://play.google.com/store/search?q=+OS+Broadcaster&c=apps) (Android 3+, h264/aac)
* Support the following clients:
	* jwplayer
	* flowplayer
	* Mobile Safari: iOS/ipad 5+, iOS/iphone 5+, should work with iOS/ipad 5+ (only is HLS is enabled)
	* http://dl.dropbox.com/u/2918563/flvplayback.swf (Flash Player 10+)
	* http://www.osmf.org/configurator/fmp/  (Flash Player 10+)

What it is
---

* For me, a week (update: two week now) of random r&d including a heavy dose of trial an error, docs ingesting, google resarch, all possible because of [these people](https://github.com/kelexel/rstream#credits). It is meant for educational purpose only. It will only setup what you tell it too.
* It uses good old Bourne shell - so it just works *out of the box* on *any* *NIX
* A set of configuration files and script to simplify deploy a full-feature streaming server CDN capable of transcoding a single FLV (h264/acc no vpx/mp3) received *via* the RTMP protocol, to multiple bitrate video streams compatible with both Adobe FLASH (RTMP) and iOS-style HTTPLiveStreaming (HLS) compatible devices.
* The "transcoder" is nothing less than a bourne script invoking ffmpeg with my set of settings, you are encouraged to experiment with these settings (specially the HLS ones)
* Transcoder has now 3x different ways of working (check Transcoding section), each mode being able to generate 720p, 480p, 340p, 240p FLV (h264/aac) streams from a single given h264/aac stream.
* IF HLS is enabled via nginx, the same broadcaster's stream will be converted to the above four streams + their equivalent in HLS streams, for a total of 8 different streams (4x RTMP and 4x HLS)
* It can now work with crtmpd only, nginx only, or both crtmpd and nginx
* It is per OS customizable - you can easily port rstream to *any* os, assuming you create your own ~/rstream/include/system-os/* files
* It is now multiple-broadcasters-friendly ! (that was a silly limitation in pre 0.5)
* It is now multi-concurent-streams-per-single-broadcaster-friendly ! (assuming you patch crtmpd with the [crtmpd-r779-transparentStream.patch](http://pastebin.com/EmNs2U9M) I wrote)

What it is NOT
---

* It is not a program, nor an application. It is a set of simple shell scripts that will let you deploy a generic config for a full featured RTMP > H264/HLS CDN.
* It is not pefect, 0.1 was written in roughly 6hours, 0.2 was  released few (sleepless) hours later, and I'm now preparing to push to 0.5 with *major* code refactoring. You should really only use this if you know what you are doing, and mostly, if you are doing on a vanilla server (i.e.: without prior specific config/files/data on it)
* It is NOT-YET production-stress-tested 
* It is NOT-YET Linux-friendly (just fork it!)
* It is NOT-YET OSX-friendly (just fork it!)
* It is NOT-YET capable of steaming vpX/mp3
* Is is NOT(-YET?) capable of installing nginx(-rtmp), crtmpd, or ffmpeg for you, you must do this by yourself !

Why crmptd + nginx-rtmp at the same time ?!
---

The ultimate goal of this is project is to provide an *easy* way for a single Wirecast broadcaster to send one stream to *any* kind of device supporting either the RTMP or HLS protocols.

At the time I'm writing these lines, two great projects exist in the Open-Source RTMP ecosystem (there are many *other* great RTMP servers out there!), crtmpdserver](http://www.rtmpd.com/), and [nginx-rtmp](https://github.com/arut/nginx-rtmp-module).

Each has it's own pros and cons, see notes bellow


Notes on crtmpd
---

It clearly appeared to me that it was a huge competitor in the world of RTMP and video broadcasting in general, specially with it's [evostream*](http://www.evostream.com) flag-ship big brother

It's main strength is the library on top of which are built every crtmpd "apps"; think of crtmpd as an advanced framework for manipulating media streams.

The frustrating part, is that if, as me, you have limited knowledge of C/C++/C#, creating your own app is probably out of the equation.

Luckily for me, they provide the sources of several *sample apps*, that even led me to produce [a piggy-style-patch for the proxypublish app]((http://pastebin.com/EmNs2U9M) allowing it to transparently relay any stream_name pushed by a broadcaster to a pre-given remoteServer.

The fact that they provide their *framework* for free is in my humble opinion fantastic, even if it lack some very useful features out of the box (HLS / exec for transcoding...), which can be easily implemented by the programming wise.

Is is worth mentioning that as of now (16/08/2012), crtmpd supports encryption over RTMPS, mostly "Adobe style" broadcaster authentication for the RTMP(S) protocols


Notes on nginx-rtmp
---

The first thing that struck me was *nginx* in the name. Anyone who ever dealt with high-availability-heavy-load-httpd setups knows nginx.
Second, the fact that it supported HLS and "exec" was enough to convince me that [nginx-rtmp](https://github.com/arut/nginx-rtmp-module/) was going to become a key element in this project.

It has a built-in trigger mechanism using http requests via customizable URLs to handle play read/record client access
It has a stats module that provides a descent efficient overview of your server's current usage

HLS is still considered experimental

nginx-rtmp is single threaded, meaning if using exec, it is strongly advised to fork your ffmpeg scripts in the background
It only supports the RTMP protocol

Is is worth mentioning that as of now (16/08/2012), nginx-rtmp only supports the RTMP protocol, and has no built-in "Adobe style" broadcast user authentication mechanism 

If using rstream in "nginx-rtmp only" mode, you will only be able to restrain broadcaster access via allow/deny rules on per IP basis, see ~rstream/etc/nginx-rtmp.conf, or nginx-rtmp docs fo examples
But I am sure this will be fixed in a few ;)

Notes on HLS
---

* HLS built-in generation **is not yet** implemented in the (free) crtmpd
* HLS built-in generation **is** implemented in the (free) nginx-rtmp (via ffmpeg)
* HLS is theoretically doable for crtmpd using ffmpeg in a standalone process (i.e.: via rstream-transcoder -run hls <streamname>)
* HLS is available in nginx-rtmp via ffmpeg, no nginx-rtmp or no ffmpeg = no HLS for you 
* HLS support requires a recent ffmpeg (!) with RTMP support enabled, and a recent (!) version of nginx-rtmp (don't forget to add HLS support, see nginx-rtmp install notes)
* HLS multi-bitrate is only available if both nginx-rtmp and ffmpeg are enabled
* HLS does not -yet- work with ffmpeg directly (aka without nginx-rtmp), because I have found no way to generate an HLS friendly -segment_list (see [this ffmpeg enhancement request](https://ffmpeg.org/trac/ffmpeg/ticket/1642))
* HLS can be i/o consumming based on the concurent number of streams being HLS transcoded. Setting up a ramdisk/tmpfs in ~rstream/etc is a *great* idea, since this is where all mpeg2ts segments will be created by ffmpeg's libs via nginx-tmp

Notes on Transcoding
---

* ffmpeg is required for transcoding, and by this, I mean you probably will need to compile it from a freshly cloned [Ffmpeg github repo](https://github.com/FFmpeg/FFmpeg)
* Since nginx-rtmp now supports "exec" on FreeBSD, it is now nginx-rtmp that invokes rstream-transcoder when a new broadcaster publishes a stream. There is no more need to have ffmpeg processes on a per streamname basis, as I was doing before with daemontools.
* I have focused all my efforts right now on transcoding with nginx, but haven't forgotten crtmpd, and I am still working on a good crtmpd way to share the streams (probably pushing them via tcp )


Todo
======

* Make crtmpd transcoding
* Make experimentations with webm/mp4 segments
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

Disclaimer
==========

I am not affiliated to either crtmpd or nginx-rtmp, nor am I trying to prove one being superior to the other.
I just have a *need* which requires me to use them in a *secific* way

If you have an existing nginx installation please backup your WHOLE NGINX configuration BEFORE running rstream !
More precisely the following files:

* /usr/local/etc/nginx/nginx.conf
* /usr/local/etc/nginx/mime.types (if used in your actual setup)

By using this software you agree to the possibility of breaking something or loosing all your data.

You understand that *rstream-transcode* is higly experimental and that pipe'ing it's output to a log file might be a VERY BAD IDEA.

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

Start rstream one time to generate a new rstream configuration file
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

Transcoding in nginx-rtmp is now controlled via nginx-rtmp itself (prior version needed a separate script). nginx-rtmp uses "exec" function to start ~rstream/bin/rstream-transcoder, a glorified wrapper-to-ffmpeg. You are encouraged to modify any settings in it that you will see fit.
Any stream pushed to the app "proxy" will be transcoded as HLS and H264 streams automagically to the following URLs:

```bash
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_720p
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_480p
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_360p
# rtmp://NGINX_RTMP_IP:NGINX_RTMP_PORT/r/NGINX_RTMP_STREAM_240p
```


Howto: Using Wirecast as a broadcaster
----

Download and install Wirecast(pro) demo from http://www.telestream.net/wirecast/overview.htm

Go to Broadcast settings (on OSX, CMD+Y)
Create a new broadcast profile profile containing:

* Input the matching url (yes the /proxy is required and fixed): rtmp://<RTMP_IP>:<RTMP_PORT>/proxy
* Set authentication settings with username "broadcast", password "n3rox". The user list is located in $HOME/etc/crtmpd-users.lua
* Set User Agent to FMLE/3.0
* Set stream name to <CRTMP_STREAM>


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

Take this *thing* as a training exercise.
First to learn the components required in a modern full featured video CDN platform.
Second, because slamming my head on the wall several times did help me understand and learn some of the key concepts behind HLS, ffmpeg, and a few other things.
If it helps you learn a thing or two, than I'm happy.
If their are peaces of it (I honestly think a few shell functions in this script are quite helpful) you want to reuse, please do so, but be fair.
People behind projects like crtmpd or nginx-rtmp are the true hero, I am only exploiting / requesting / admiring / troubleshooting / bug-reporting / enhancement-suggesting their work.

Open-Source 4 ever.
