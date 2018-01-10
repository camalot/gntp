# GNTP

A command line script to call growl notification

# Installation 

```
curl --insecure -sL "https://artifactory.bit13.local:443/artifactory/generic-local/gntp/latest/gntp-latest.zip" -o /tmp/gntp.zip
cd /tmp || exit 9;
unzip gntp.zip -d /;
mv /usr/local/bin/gntp.sh /usr/local/bin/gntp;
chmod +x /usr/local/bin/gntp;
chmod +x /usr/local/bin/gntp-send;
find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;
```

# Docker

```
docker run \
	-e GNTP_HOST=YOUR_GNTP_HOST \
	-e GNTP_PASSWORD=HOST_GNTP_PASSWORD 
	docker.artifactory.bit13.local/camalot/gntp:latest \
	--app="APP NAME" --title="MESSAGE TITLE" --message="MESSAGE"
```
