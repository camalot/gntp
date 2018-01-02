#!/usr/bin/env bash

base_dir=$(dirname $0);

. ${base_dir}/shared.sh;


get_opts() {
	while getopts ":p:f" opt; do
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

ls -lfA "${base_dir}/../dist/";

unzip "${base_dir}/../dist/$opt_project_name-$opt_version.zip" -d "${base_dir}/../dist/"
