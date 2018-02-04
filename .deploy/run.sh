#!/usr/bin/env bash

set -e;

base_dir=$(dirname "$0");
# shellcheck source=/dev/null
source "${base_dir}/shared.sh";

get_opts() {
	while getopts ":v:n:o:f" opt; do
		case $opt in
			v) export opt_version="$OPTARG";
			;;
			n) export opt_name="$OPTARG";
			;;
			o) export opt_org="$OPTARG";
			;;
			f) export opt_force=1;
			;;
	    \?) echo "Invalid option -$OPTARG" >&2;
	    exit 1;
	    ;;
	  esac;
	done;

	return 0;
};


get_opts "$@";

FORCE_DEPLOY=${opt_force:-0};
BUILD_PROJECT="${opt_name:-"${CI_PROJECT_NAME}"}";
BUILD_PUSH_REGISTRY="${DOCKER_REGISTRY}";
BUILD_VERSION="${opt_version:-"${CI_BUILD_VERSION:-"latest"}"}";
BUILD_ORG="${opt_org}";

DOCKER_IMAGE="${BUILD_ORG}/${BUILD_PROJECT}:${BUILD_VERSION}";

[[ -z "${BUILD_PROJECT// }" ]] && __error "Environment variable 'CI_PROJECT_NAME' missing or empty.";
[[ -z "${BUILD_VERSION// }" ]] && __error "Environment variable 'CI_BUILD_VERSION' missing or empty.";
[[ -z "${BUILD_PUSH_REGISTRY// }" ]] && __error "Environment variable 'DOCKER_REGISTRY' missing or empty.";
[[ -z "${BUILD_ORG// }" ]] && __error "Argument '-o' (organization) is missing or empty.";
[[ -z "${ARTIFACTORY_USERNAME// }" ]] && __error "Environment variable 'ARTIFACTORY_USERNAME' missing or empty.";
[[ -z "${ARTIFACTORY_PASSWORD// }" ]] && __error "Environment variable 'ARTIFACTORY_PASSWORD' missing or empty.";

docker login --username "${ARTIFACTORY_USERNAME}" "${BUILD_PUSH_REGISTRY}" --password-stdin <<< "${ARTIFACTORY_PASSWORD}";

echo "${DOCKER_REGISTRY}/${DOCKER_IMAGE}";

docker pull "${DOCKER_REGISTRY}/${DOCKER_IMAGE}";

# CHECK IF IT IS CREATED, IF IT IS, THEN DEPLOY
DC_INFO=$(docker ps --all --format "table {{.Status}}\t{{.Names}}" | awk '/emojipacks$/ {print $0}');
__info "DC_INFO: $DC_INFO"
DC_STATUS=$(echo "${DC_INFO}" | awk '{print $1}');
__info "DC_STATUS: $DC_STATUS"
__info "FORCE_DEPLOY: $FORCE_DEPLOY"
if [[ -z "${DC_STATUS}" ]] && [ $FORCE_DEPLOY -eq 0 ]; then
	__warning "Container '$DOCKER_IMAGE' not deployed. Skipping deployment";
	exit 0;
fi

if [[ ! $DC_STATUS =~ ^Exited$ ]]; then
  __info "stopping container";
	docker stop "${BUILD_PROJECT}" || __warning "Unable to stop '${BUILD_PROJECT}'";
fi
if [[ ! -z "${DC_INFO}" ]]; then
  __info "removing image";
	docker rm "${BUILD_PROJECT}" || __warning "Unable to remove '${BUILD_PROJECT}'";
fi

docker run -d \
	--user 0 \
	--rm \
	--name "${BUILD_PROJECT}" \
	-t "${DOCKER_IMAGE}";
