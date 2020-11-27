#!/usr/bin/env bash

# include_bash_utils must be copied into every script because it is needed
# to find bash_utils and load it.
function include_bash_utils() {
    local SCRIPT_ABS_PATH=$([[ $0 = /* ]] && echo "$0" || echo "$PWD/${0#./}")
    local RELATIVE_PATH_TO_BASH_UTILS=$1
    local SCRIPT_ABS_DIR=$(dirname ${SCRIPT_ABS_PATH})
    local BASH_UTILS_PATH=$([[ ${RELATIVE_PATH_TO_BASH_UTILS} = /* ]] \
        && echo "${RELATIVE_PATH_TO_BASH_UTILS}" \
        || echo "${SCRIPT_ABS_DIR}/${RELATIVE_PATH_TO_BASH_UTILS#./}")
    source ${BASH_UTILS_PATH}
}

include_bash_utils ./tools/bash_utils.sh

if [[ -z ${KUBERNETES_NAMESPACE} ]]; then
    echo "KUBERNETES_NAMESPACE environment variable must provide the name of the "
    echo "kubernetes namespace to deploy into."
    exit 1
fi

if util::command_exists "stern"; then
    echo "FOUND stern AND WILL USE IT TO TAIL LOGS FROM ALL CONTAINERS."
    stern keda-\w* --namespace ${KUBERNETES_NAMESPACE}
else
    echo "DID NOT FIND stern INSTALLED."
    echo "YOU SHOULD GET STERN TO SEE LOGS FROM ALL CONTAINERS."
    echo "Will fallback to kubectl logs."
	kubectl logs -f deployment/keda-aws-sqs-queue-scaler \
		-n ${KUBERNETES_NAMESPACE}
fi