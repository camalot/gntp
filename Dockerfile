# FROM alpine:latest
FROM debian:latest 


ARG PROJECT_NAME="gntp"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG GNTP_VERSION="${BUILD_VERSION}"
ARG GNTP_APP="${PROJECT_NAME}-${BUILD_VERSION}"
ARG PUID=1000
ARG PGID=1000

ENV GNTP_APP="${GNTP_APP}"

LABEL \
	LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" \
	VERSION="${BUILD_VERSION}" \
	MAINTAINER="camalot <camalot@gmail.com>"

RUN groupadd -g ${PGID} abc \
	&& useradd -d "/home/abc" -u "${PUID}" -g "${PGID}" -m -s /bin/bash "abc" && \
	chsh -s /bin/bash abc;

RUN \
	apt-get update && \
	apt-get install curl unzip bash -yq && \
	rm -rf /var/cache/apt/* && \
	apt-get clean && \
	curl --insecure -s "https://artifactory.bit13.local:443/artifactory/generic-local/gntp/${GNTP_VERSION}/gntp-${GNTP_VERSION}.zip" -o /tmp/gntp.zip && \
	cd /tmp && \
	unzip gntp.zip -d / && \
	mv /usr/local/bin/gntp.sh /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp-send;

RUN find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;

USER abc 

WORKDIR "/usr/local/bin"

ENTRYPOINT ["/usr/local/bin/gntp"]
