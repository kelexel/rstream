-- Start of the configuration. This is the only node in the config file. 
-- The rest of them are sub-nodes
configuration=
{
	daemon=false,
	pathSeparator="/",
	logAppenders=
	{
		{
			name="console appender",
			type="coloredConsole",
			level=6
		},
	},
	applications=
	{
		rootDirectory="applications",
		{
			name="proxypublish",
			description="Application for forwarding streams to another RTMP server",
			protocol="dynamiclinklibrary",
			mediaFolder="_HOME_/shared/media",
			--[[aliases={
				"proxy", "720p", "480p", "320p",
			},]]--
			acceptors =
			{
				{
					ip="_CRTMPD_RTMP_IP_",
					port=_CRTMPD_RTMP_PORT_,
					protocol="inboundRtmp"
				},
				--[[TRANSCODING{
					ip="_CRTMPD_LIVEFLV_IP_",
					port=_CRTMPD_LIVEFLV_PORT_,
					protocol="inboundLiveFlv"
				},TRANSCODING]]--
			},
			abortOnConnectError=false,
			targetServers= 
			{
				--[[PROXY{
					targetUri="_CRTMPD_PROXY_URL_/",
					targetStreamName="_CRTMPD_PROXY_DSTREAM_",
					localStreamName="_CRTMPD_PROXY_LSTREAM_",
					--emulateUserAgent="FMLE/3.0 (compatible; FMSc/1.0 http://www.rtmpd.com)"
				},PROXY]]--
			},
			authentication=
			{
				rtmp={
						type="adobe",
						encoderAgents=
						{
							"FMLE/3.0 (compatible; FMSc/1.0)",
						},
						usersFile="_HOME_/etc/crtmpd-users.lua",
				},
			},
			validateHandshake=false,
			default=false,
		},
	},
}

