# GNTP

A command line script to call growl notification

# Installation 

```
curl -sL "https://github.com/camalot/gntp-send/releases/download/1.0.23/gntp-send-1.0.23.zip" -o /tmp/gntp-send.zip;
curl -sL "https://github.com/camalot/gntp/releases/download/VERSION/gntp-VERSION.zip" -o /tmp/gntp.zip;
cd /tmp || exit 9;
unzip gntp-send.zip -d /;
unzip gntp.zip -d /;
mv /usr/local/bin/gntp.sh /usr/local/bin/gntp;
chmod +x /usr/local/bin/gntp;
chmod +x /usr/local/bin/gntp-send;
find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;
```

# Docker

### Environment Variables

`GNTP_HOST`: (Required) GNTP Host to push the message to
`GNTP_PASSWORD`: The password for pushing to the `GNTP_HOST`
`GNTP_APP`: Another way to set the app name that is identified to the `GNTP_HOST`

```
docker run \
	-e GNTP_HOST=YOUR_GNTP_HOST \
	-e GNTP_PASSWORD=HOST_GNTP_PASSWORD \
	-e GNTP_APP="APP NAME"\ 
	camalot/gntp:latest \
	--title="MESSAGE TITLE" --message="MESSAGE"
```


## References

[gntp-send github fork](https://github.com/camalot/gntp-send)  
[gntp-send github](https://github.com/mattn/gntp-send)  
[gntp-send launchpad](https://launchpad.net/~mattn/+archive/ubuntu/gntp-send)
