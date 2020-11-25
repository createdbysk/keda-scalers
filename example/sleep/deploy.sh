# Ensure that the execution only happens with the dev account credentials.
# I know - this is brittle - Remember, this is a POC.
DEPLOYMENT_ACCOUNT=$(aws sts get-caller-identity | jq ".Account" -r)
if [[ "$DEPLOYMENT_ACCOUNT" != "969204706979" ]]; then
    echo "Seems like you have not obtained assumed role credentials to the dev environment."
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

QUEUE_URL=$(aws sqs list-queues --queue-name ${QUEUE_NAME} | \
    jq ".QueueUrls[0]" -r)

helm install keda-aws-sqs-queue-scaler keda-scalers/keda-aws-sqs-queue-scaler \
    -n keda \
    --set keda.awsAccessKeyId=${AWS_ACCESS_KEY_ID} \
    --set keda.awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
    --set keda.awsSessionToken=${AWS_SESSION_TOKEN} \
    --set keda.awsSqsQueueName=${QUEUE_NAME} \
    --set keda.awsSqsQueueUrl=${QUEUE_URL} \
    --set keda.awsRegion=${AWS_DEFAULT_REGION}
