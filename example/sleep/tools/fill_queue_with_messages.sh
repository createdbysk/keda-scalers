#!/usr/bin/env bash

NUMBER_OF_MESSAGES=$1

# Sleep anywhere between 1 and 120 seconds.
MIN_SLEEP_SECONDS=1
MAX_SLEEP_SECONDS=119

# Ensure that the execution only happens with the dev account credentials.
# I know - this is brittle - Remember, this is a POC.
DEPLOYMENT_ACCOUNT=$(aws sts get-caller-identity | jq ".Account" -r)
if [[ "$DEPLOYMENT_ACCOUNT" != "969204706979" ]]; then
    echo "Seems like you have not obtained assumed role credentials to the dev environment."
    exit 1
fi

if [[ -z ${NUMBER_OF_MESSAGES} ]]; then
    echo "Usage: $0 number_of_messages"
    exit 1
fi

if [[ -z ${QUEUE_NAME} ]]; then
    echo "QUEUE_NAME environment variable must provide the name of the queue "
    echo "that scales this deployment."
    exit 1
fi

QUEUE_URL=$(aws sqs list-queues --queue-name ${QUEUE_NAME} | \
    jq ".QueueUrls[0]" -r)

for x in $(seq 1 ${NUMBER_OF_MESSAGES})
do
    MESSAGE="{\"message_number\":${x},\"sleep_seconds\":${SLEEP_SECONDS}}"
    echo "${MESSAGE}"
    SLEEP_SECONDS=$[ ${RANDOM} % ${MAX_SLEEP_SECONDS} + ${MIN_SLEEP_SECONDS} ]
    aws sqs send-message \
    --message-body="${MESSAGE}" \
    --queue-url=${QUEUE_URL}
done