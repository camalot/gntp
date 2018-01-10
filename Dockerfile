FROM alpine:latest

ARG PROJECT_NAME="jenkins-agent-base"
ARG BUILD_VERSION="1.0.0-snapshot"

LABEL \
	LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" \
	VERSION="${BUILD_VERSION}" \
	MAINTAINER="camalot <camalot@gmail.com>"

RUN \
	apk add --no-cache curl unzip bash && \
	curl --insecure -s "https://artifactory.bit13.local:443/artifactory/generic-local/gntp/${BUILD_VERSION}/gntp-${BUILD_VERSION}.zip" -o /tmp/gntp.zip && \
	cd /tmp && \
	unzip gntp.zip -d / && \
	mv /usr/local/bin/gntp.sh /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp && \
	chmod +x /usr/local/bin/gntp-send;

RUN find /usr/lib/libgrowl.* -type f -exec chmod +rx {} \;

CMD [ "/bin/bash" ]
ENTRYPOINT ["/usr/local/bin/gntp"]
