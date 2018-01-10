#!/usr/bin/env bash

base_dir=$(dirname "$0");

# shellcheck source=.deploy/shared.sh
# shellcheck disable=SC1091
source "${base_dir}/shared.sh";

get_opts() {
	while getopts ":n:v:" opt; do
	  case $opt in
			n) export opt_project_name="$OPTARG";
			;;
			v) export opt_version="$OPTARG";
			;;
	    \?) __error "Invalid option -$OPTARG";
	    ;;
	  esac;
	done;
	return 0;
};

get_opts "$@";


PROJECT_NAME="${opt_project_name:-"${CI_PROJECT_NAME}"}";
BUILD_VERSION=${CI_BUILD_VERSION:-"1.0.0-snapshot"};
DOCKER_ORG="camalot";
tag="${DOCKER_ORG}/${PROJECT_NAME}";

[[ -p "${PROJECT_NAME// }" ]] && __error "'-p' (project name) attribute is required.";
[[ -p "${BUILD_VERSION// }" ]] && __error "'-v' (version) attribute is required.";


mkdir -p "${WORKSPACE}/dist/";
pushd . || exit 9;
cd "${WORKSPACE}/root" || exit 9;
pwd;
zip -r "${PROJECT_NAME}-${BUILD_VERSION}.zip" -- *;
mv "${PROJECT_NAME}-${BUILD_VERSION}.zip" "${WORKSPACE}/dist/";
popd || exit 9;



