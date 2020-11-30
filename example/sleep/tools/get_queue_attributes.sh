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

include_bash_utils ./bash_utils.sh
util::include ./aws_utils.sh

echo "Attributes of ${QUEUE_NAME}"
QUEUE_URL=$(util::aws::get_queue_url ${QUEUE_NAME}) \
    || fail "${QUEUE_NAME} not found. Do you have appropriate AWS credentials?"

aws sqs get-queue-attributes --attribute-names All --queue-url ${QUEUE_URL}
