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
	    \?) echo "Invalid option -$OPTARG" >&2;
	    exit 1;
	    ;;
	  esac;
	done;
	return 0;
};

get_opts "$@";

base_dir=$(dirname "$0");

PROJECT_NAME="${opt_project_name:-"${CI_PROJECT_NAME}"}";
PUSH_REGISTRY="${DOCKER_PUSH_REGISTRY:-"docker-local.artifactory.bit13.local"}"
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


tag_name_latest="${tag}:latest";
tag_name_ver="${tag}:${BUILD_VERSION}";

docker build $opt_force--pull \
	--build-arg BUILD_VERSION="${BUILD_VERSION}" \
	--build-arg PORJECT_NAME="${PROJECT_NAME}" \
	--tag "${tag_name_ver}" \
	"${base_dir}/../";

[[ ! $BUILD_VERSION =~ -snapshot$ ]] && \
	docker tag "${tag_name_ver}" "${tag_name_latest}" && \
	docker tag "${tag_name_ver}" "${PUSH_REGISTRY}/${tag_name_latest}" && \
	docker push "${PUSH_REGISTRY}/${tag_name_latest}";

docker tag "${tag_name_ver}" "${PUSH_REGISTRY}/${tag_name_ver}";
docker push "${PUSH_REGISTRY}/${tag_name_ver}";

