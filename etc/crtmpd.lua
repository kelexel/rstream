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
			mediaFolder="/home/rstream/shared/media",
			--[[alias=[
				"proxy", "720p", "480p", "320p",
			],]]--
			acceptors =
			{
				{
					ip="46.105.37.199",
					port=1936,
					protocol="inboundRtmp"
				},
				{
					ip="46.105.37.199",
					port=21935,
					protocol="inboundLiveFlv"
				},
			},
			abortOnConnectError=false,
			targetServers= 
			{
				{
					targetUri="rtmp://stream02.ovh.new-net.net/proxy",
					targetStreamName="test",
					localStreamName="test",
					--emulateUserAgent="FMLE/3.0 (compatible; FMSc/1.0 http://www.rtmpd.com)"
				},
			},
			authentication=
			{
				rtmp={
						type="adobe",
						encoderAgents=
						{
							"FMLE/3.0 (compatible; FMSc/1.0)",
						},
						usersFile="/home/rstream/etc/crtmpd-users.lua",
				},
			},
			validateHandshake=false,
			--default=true,
		},
	},
}

