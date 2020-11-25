#!/usr/bin/env bash

if [[ -z ${KUBERNETES_NAMESPACE} ]]; then
    echo "KUBERNETES_NAMESPACE environment variable must provide the name of the "
    echo "kubernetes namespace to deploy into."
    exit 1
fi

function stern_exists() {
    command -v stern &> /dev/null || exit 1
}

if stern_exists; then
    echo "FOUND stern AND WILL USE IT TO TAIL LOGS FROM ALL CONTAINERS."
    stern keda-\w* --namespace ${KUBERNETES_NAMESPACE}
else
    echo "DID NOT FIND stern INSTALLED."
    echo "YOU SHOULD GET STERN TO SEE LOGS FROM ALL CONTAINERS."
    echo "Will fallback to kubectl logs."
	kubectl logs -f deployment/keda-aws-sqs-queue-scaler \
		-n ${KUBERNETES_NAMESPACE}
fi