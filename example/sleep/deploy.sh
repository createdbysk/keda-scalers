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
util::include ./tools/aws_utils.sh

if [[ -z ${CHARTS_PATH} ]]; then
    echo "CHARTS_PATH environment variable must provide relative path "
    echo "to the helm chart path."
    exit 1
fi

if [[ -z ${KUBERNETES_NAMESPACE} ]]; then
    echo "KUBERNETES_NAMESPACE environment variable must provide the name of the "
    echo "kubernetes namespace to deploy into."
    exit 1
fi

if [[ -z ${HELM_NAME} ]]; then
    echo "HELM_NAME environment variable must provide the name for helm."
    exit 1
fi

if [[ -z ${QUEUE_NAME} ]]; then
    echo "QUEUE_NAME environment variable must provide the name of the queue "
    echo "that scales this deployment."
    exit 1
fi

if [[ -z ${AWS_DEFAULT_REGION} ]]; then
    echo "AWS_DEFAULT_REGION environment variable must provide the name of the region."
    exit 1
fi

QUEUE_URL=$(util::aws::get_queue_url ${QUEUE_NAME}) \
    || fail "${QUEUE_NAME} not found. Do you have appropriate AWS credentials?"

if [[ ! -z ${DEBUG} ]] && [[ "${DEBUG}"=="true" ]]; then
    echo "DEBUG is set to ${DEBUG}"
    echo "Will dry-run"
    ADDITIONAL_PARAMETERS="--dry-run --debug"
fi

CHART_ABSPATH=$(util::abspath_given_path_relative_to_script ${CHARTS_PATH})

helm install ${HELM_NAME} ${CHARTS_PATH}/keda-aws-sqs-queue-scaler \
    -n ${KUBERNETES_NAMESPACE} \
    ${ADDITIONAL_PARAMETERS} \
    --set keda.awsAccessKeyId=${AWS_ACCESS_KEY_ID} \
    --set keda.awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
    --set keda.awsSessionToken=${AWS_SESSION_TOKEN} \
    --set keda.awsSqsQueueName=${QUEUE_NAME} \
    --set keda.awsSqsQueueUrl=${QUEUE_URL} \
    --set keda.awsRegion=${AWS_DEFAULT_REGION} \
    -f helm/scaler-values.yaml
