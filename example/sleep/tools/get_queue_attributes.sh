#!/usr/bin/env bash

echo "Attributes of ${QUEUE_NAME}"
QUEUE_URL=$(aws sqs list-queues --queue-name ${QUEUE_NAME} | \
    jq ".QueueUrls[0]" -r)
aws sqs get-queue-attributes --attribute-names All --queue-url ${QUEUE_URL}
