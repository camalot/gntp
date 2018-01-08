#!/usr/bin/env bash
__error() {
	RED='\033[0;31m';
	NC='\033[0m';
	dt=$(date "+%F %T");
	(>&2 echo -e "${RED}[$dt]\tERROR\t$(basename $0)\t${1:-"Unknown Error"}${NC}");
	exit 9;
}
__warning() {
	YELLOW='\033[0;33m';
	NC='\033[0m';
	dt=$(date "+%F %T");
	(>&2 echo -e "${YELLOW}[$dt]\WARNING\t$(basename $0)\t${1:-"Unknown Warning"}${NC}");
}

__gntp() {
	for i in "$@"; do
		case $i in
			-a=*|--app=*)
				_opt_app="${i#*=}";
				shift; # past argument=value
			;;
			-t=*|--title=*)
				_opt_title="${i#*=}";
				shift; # past argument=value
			;;
			-m=*|--message=*)
				_opt_message="${i#*=}";
				shift; # past argument=value
			;;
			*)
				__error "Unknown option '$i'";
			;;
		esac
	done
	app_name="${_opt_app:-"${GNTP_APP}"}";
	[[ -z "${GNTP_PASSWORD// }" ]] && __error "Environment Variable 'GNTP_PASSWORD' was not defined";
	[[ -z "${GNTP_HOST// }" ]] && __error "Environment Variable 'GNTP_HOST' was not defined";

	[[ -z "${_opt_title// }" ]] && __error "Missing required title argument (-t|--title)";
	[[ -z "${app_name// }" ]] && __error "Missing required title argument (-a|--app)";
	[[ -z "${_opt_message// }" ]] && __error "Missing required message argument (-m|--message)";

	# gntp-send: [-u] [-i] [-a APPNAME] [-n NOTIFY] [-s SERVER:PORT] [-p PASSWORD] title message [icon] [url]
	echo "gntp-send -s \"${GNTP_HOST}\" -a \"${app_name}\" -p \"*******************\" \"$_opt_title\" \"$_opt_message\"";
	gntp-send \
	-s "${GNTP_HOST}" \
	-a "${app_name:-"${JENKINS_CLOUD_ID}-${DOCKER_CONTAINER_ID}"}" \
	-p "${GNTP_PASSWORD}" \
	"$_opt_title" \
	"$_opt_message";
}

__gntp $@;
