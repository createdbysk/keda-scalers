# This file is expected to be sourced into other bash scripts
# and not used directly.

# USAGE: 
#   get_queue_url QUEUE_NAME || fail "Failure message"
function util::aws::get_queue_url() {
    local QUEUE_NAME=$1

    local RESULT=$(aws sqs list-queues --queue-name ${QUEUE_NAME})
    if [[ "$?" == "0" ]] && [[ ! -z ${RESULT} ]]; then
        echo ${RESULT} | jq ".QueueUrls[0]" -r
    else
        exit 1
    fi
}

