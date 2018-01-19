#!/usr/bin/env bash

base_dir=$(dirname "$0");

# shellcheck source=.deploy/shared.sh
# shellcheck disable=SC1091
source "${base_dir}/shared.sh";

get_opts() {
	while getopts ":n:v:f" opt; do
	  case $opt in
			n) export opt_project_name="$OPTARG";
			;;
			v) export opt_version="$OPTARG";
			;;
			f) export opt_force="--no-cache ";
			;;
	    \?) __error "Invalid option -$OPTARG";
	    ;;
	  esac;
	done;
	return 0;
};

get_opts "$@";


PROJECT_NAME="${opt_project_name:-"${CI_PROJECT_NAME}"}";
PUSH_REGISTRY="${DOCKER_PUSH_REGISTRY}";
BUILD_VERSION=${CI_BUILD_VERSION:-"1.0.0-snapshot"};
DOCKER_ORG="camalot";
tag="${DOCKER_ORG}/${PROJECT_NAME}";
tag_name_latest="${tag}:latest";
tag_name_ver="${tag}:${BUILD_VERSION}";

[[ -z "${PROJECT_NAME// }" ]] && __error "'-p' (project name) attribute is required.";
[[ -z "${BUILD_VERSION// }" ]] && __error "'-v' (version) attribute is required.";

docker build $opt_force--pull \
	--build-arg BUILD_VERSION="${BUILD_VERSION}" \
	--build-arg PROJECT_NAME="${PROJECT_NAME}" \
	--tag "${tag_name_ver}" \
	"${base_dir}/../";

if [[ ! $BUILD_VERSION =~ -snapshot$ ]]; then
	docker tag "${tag_name_ver}" "${tag_name_latest}";
	
	[[ ! -z "${PUSH_REGISTRY// }" ]] && \
		docker tag "${tag_name_ver}" "${PUSH_REGISTRY}/${tag_name_latest}" && \
		docker push "${PUSH_REGISTRY}/${tag_name_latest}";

	[[ ! -z "${DOCKER_HUB_USERNAME// }" ]] && [[ ! -z "${DOCKER_HUB_PASSWORD// }" ]] && \
		docker login --username "${DOCKER_HUB_USERNAME}" --password "${DOCKER_HUB_PASSWORD}" && \
		docker push "${tag_name_latest}" && \
		docker push "${tag_name_ver}";
fi

[[ ! -z "${PUSH_REGISTRY// }" ]] && \
	docker tag "${tag_name_ver}" "${PUSH_REGISTRY}/${tag_name_ver}" && \
	docker push "${PUSH_REGISTRY}/${tag_name_ver}";

