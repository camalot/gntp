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

get_opts $@;

echo "${opt_project_name}-${opt_version}.zip";
mkdir -p "${WORKSPACE}/dist/";
pushd;
cd ${WORKSPACE}/root;
zip -r "${WORKSPACE}/dist/${opt_project_name}-${opt_version}.zip" "${WORKSPACE}/root/usr";


