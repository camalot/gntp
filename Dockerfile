# FROM alpine:latest
FROM debian:latest 


ARG PROJECT_NAME="gntp"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG GNTP_VERSION="${BUILD_VERSION}"

ARG PUID=1000
ARG PGID=1000

LABEL \
	LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" \
	VERSION="${BUILD_VERSION}" \
	MAINTAINER="camalot <camalot@gmail.com>"


# RUN addgroup -g ${PGID} abc && \
# 	adduser -u ${PUID} -G abc -s /bin/bash -D abc;

RUN groupadd -g ${PGID} abc \
	&& useradd -d "/home/abc" -u "${PUID}" -g "${PGID}" -m -s /bin/bash "abc" && \
	chsh -s /bin/bash abc;


RUN \
	apt-get update && \
	apt-get install --no-cache curl unzip bash -yq && \
	rm -rf /var/cache/apt/* && \
	apt-get clean && \
	curl --insecure -s "https://artifactory.bit13.local:443/artifactory/generic-local/gntp/${GNTP_VERSION}/gntp-${GNTP_VERSION}.zip" -o /tmp/gntp.zip && \
	cd /tmp && \
	unzip gntp.zip -d / && \
	mv /usr/local/bin/gntp.sh /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp-send;

RUN find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;

RUN \
	ls -lFA /usr/local/bin && \
	ls -lFA /usr/lib

USER abc 

WORKDIR "/usr/local/bin"

ENTRYPOINT ["/usr/local/bin/gntp"]
