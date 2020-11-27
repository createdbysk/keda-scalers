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

NUMBER_OF_MESSAGES=$1

# Sleep anywhere between 1 and 120 seconds.
MIN_SLEEP_SECONDS=1
MAX_SLEEP_SECONDS=119

if [[ -z ${NUMBER_OF_MESSAGES} ]]; then
    echo "Usage: $0 number_of_messages"
    exit 1
fi

if [[ -z ${QUEUE_NAME} ]]; then
    echo "QUEUE_NAME environment variable must provide the name of the queue "
    echo "that scales this deployment."
    exit 1
fi

QUEUE_URL=$(util::aws::get_queue_url ${QUEUE_NAME}) || \
    fail "${QUEUE_NAME} not found. Do you have appropriate AWS credentials?"

for x in $(seq 1 ${NUMBER_OF_MESSAGES})
do
    SLEEP_SECONDS=$[ ${RANDOM} % ${MAX_SLEEP_SECONDS} + ${MIN_SLEEP_SECONDS} ]
    MESSAGE="{\"message_number\":${x},\"sleep_seconds\":${SLEEP_SECONDS}}"
    echo "${MESSAGE}"
    aws sqs send-message \
        --message-body="${MESSAGE}" \
        --queue-url=${QUEUE_URL}
done