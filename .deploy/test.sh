#!/usr/bin/env bash

base_dir=$(dirname $0);

. ${base_dir}/shared.sh;


get_opts() {
	while getopts ":n:v:" opt; do
	  case $opt in
			n) export opt_project_name="$OPTARG";
			;;
			v) export opt_version="$OPTARG";
			;;
	    \?) echo "Invalid option -$OPTARG" >&2;
	    exit 1;
	    ;;
	  esac;
	done;

	[[ -p "${opt_project_name// }" ]] && __error "'-p' (project name) attribute is required.";
	[[ -p "${opt_version// }" ]] && __error "'-v' (version) attribute is required.";

	return 0;
};

get_opts "$@";

unzip "${WORKSPACE}/dist/$opt_project_name-$opt_version.zip" -d "${WORKSPACE}/dist/" > /dev/null

[[ ! -d ${WORKSPACE}/dist/usr ]] && __error "usr/ directory missing";
[[ ! -d ${WORKSPACE}/dist/usr/local ]] && __error "usr/local directory missing";
[[ ! -d ${WORKSPACE}/dist/usr/local/bin ]] && __error "usr/local/bin directory missing";
[[ ! -f ${WORKSPACE}/dist/usr/local/bin/gntp.sh ]] && __error "usr/local/bin/gntp missing";

rm -rf "${WORKSPACE}/dist/usr";
