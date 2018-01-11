# FROM alpine:latest
FROM debian:latest 


ARG PROJECT_NAME="gntp"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG GNTP_VERSION="${BUILD_VERSION}"
ARG GNTP_APP="${PROJECT_NAME}-${BUILD_VERSION}"
ARG PUID=1000
ARG PGID=1000

ARG GNTP_SEND_VERSION="latest"
ARG GNTP_VERSION="latest"
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
	gntp_send_v=$(if [[ "${GNTP_SEND_VERSION}" =~ ^latest$ ]]; then curl -s https://api.github.com/repos/camalot/gntp-send/releases/latest | jq -r '.name'; else echo "${GNTP_SEND_VERSION}"; fi) && \
	gntp_v=$(if [[ "${GNTP_VERSION}" =~ ^latest$ ]]; then curl -s https://api.github.com/repos/camalot/gntp/releases/latest | jq -r '.name'; else echo "${GNTP_VERSION}"; fi) && \
	curl -Ls "https://github.com/camalot/gntp-send/releases/download/${gntp_send_v}/gntp-send-${gntp_send_v}.zip" -o /tmp/gntp-send.zip && \
	curl -Ls "https://github.com/camalot/gntp/releases/download/${gntp_v}/gntp-${gntp_v}.zip" -o /tmp/gntp.zip && \
	cd /tmp && \
	unzip gntp.zip -d / && \
	unzip gntp-send.zip -d / && \
	mv /usr/local/bin/gntp.sh /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp-send;

RUN find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;

USER abc 

WORKDIR "/usr/local/bin"

ENTRYPOINT ["/usr/local/bin/gntp"]
