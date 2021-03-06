# FROM alpine:latest
FROM debian:latest 


ARG PROJECT_NAME="gntp"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG GNTP_VERSION="${BUILD_VERSION}"
ARG GNTP_APP="${PROJECT_NAME}-${BUILD_VERSION}"
ARG PUID=1000
ARG PGID=1000

ARG GNTP_SEND_VERSION="1.0.23"
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
	apt-get install curl unzip bash jq -yq && \
	rm -rf /var/cache/apt/* && \
	apt-get clean;

RUN \
	curl -Ls "https://github.com/camalot/gntp-send/releases/download/${GNTP_SEND_VERSION}/gntp-send-${GNTP_SEND_VERSION}.zip" -o /tmp/gntp-send.zip && \
	curl -Ls "https://github.com/camalot/gntp/releases/download/${BUILD_VERSION}/gntp-${BUILD_VERSION}.zip" -o /tmp/gntp.zip && \
	cd /tmp && \
	unzip gntp.zip -d / && \
	unzip gntp-send.zip -d / && \
	mv /usr/local/bin/gntp.sh /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp-send;

RUN find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;

WORKDIR "/usr/local/bin"

ENTRYPOINT ["/usr/local/bin/gntp"]
