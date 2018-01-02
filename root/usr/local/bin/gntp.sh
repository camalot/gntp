#!/usr/bin/env bash
__error() {
	(>&2 echo "${1:-"Unknown Error"}");
	exit 9;
}

__opts() {
	while getopts ":t:m:" opt; do
	  case $opt in
      t) export opt_title="$OPTARG";
      ;;
      m) export opt_message="$OPTARG";
      ;;
    	\?) 
				echo "Invalid option -$OPTARG" >&2;
	    	exit 1;
	    ;;
	  esac;
	done;

	return 0;
};

__gntp() {
    [[ -p "${GNTP_PASSWORD// }" ]] && __error "Environment Variable 'GNTP_PASSWORD' was not defined";
    [[ -p "${GNTP_HOST// }" ]] && __error "Environment Variable 'GNTP_HOST' was not defined";
    [[ -p "${GNTP_APP// }" ]] && __error "Environment Variable 'GNTP_HOST' was not defined";

    __opts $@;

    # gntp-send: [-u] [-i] [-a APPNAME] [-n NOTIFY] [-s SERVER:PORT] [-p PASSWORD] title message [icon] [url]
    echo "gntp-send -s \"${GNTP_HOST}\" -a \"${GNTP_APP}\" -p \"*******************\" \"$opt_title\" \"$opt_message\"";
    gntp-send \
    -s "${GNTP_HOST}" \
    -a "${GNTP_APP:-"${JENKINS_CLOUD_ID}-${DOCKER_CONTAINER_ID}"}" \
    -p "${GNTP_PASSWORD}" \
    "$opt_title" \
    "$opt_message";
}

__gntp $@;
