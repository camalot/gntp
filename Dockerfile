FROM alpine:latest

ARG PROJECT_NAME="jenkins-agent-base"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG GNTP_VERSION="${BUILD_VERSION}"

ARG user=gntp
ARG group=gntp
ARG uid=1000
ARG gid=1000
ARG GNTP_HOME=/home/${user}


LABEL \
	LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" \
	VERSION="${BUILD_VERSION}" \
	MAINTAINER="camalot <camalot@gmail.com>"


RUN groupadd -g ${gid} ${group} \
	&& useradd -d "${GNTP_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}" && \
	chsh -s /bin/bash ${user};
	
RUN \
	apk add --no-cache curl unzip bash && \
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

CMD [ "/bin/bash" ]
ENTRYPOINT ["/usr/local/bin/gntp"]
