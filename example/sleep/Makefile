KEDA_NAMESPACE=keda
KEDA_SCALER_NAMESPACE=keda-scaler
HELM_NAME=keda-aws-sqs-queue-scaler

ifndef NUMBER_OF_MESSAGES
override NUMBER_OF_MESSAGES = 10
endif

guard-%:
	@ if [ "${${*}}" = "" ]; then \
        echo "Environment variable $* not set"; \
        exit 1; \
	fi

undeploy:
	-helm delete ${HELM_NAME} -n ${KEDA_SCALER_NAMESPACE}

unbuild:
	-docker rmi satvidh/keda-aws-sqs-queue-scaler-example-sleep:1.0.0

build:
	docker build . -t satvidh/keda-aws-sqs-queue-scaler-example-sleep:1.0.0

deploy: guard-QUEUE_NAME guard-AWS_DEFAULT_REGION guard-AWS_ACCESS_KEY_ID guard-AWS_SECRET_ACCESS_KEY guard-AWS_SESSION_TOKEN
	KUBERNETES_NAMESPACE=${KEDA_SCALER_NAMESPACE} \
	HELM_NAME=${HELM_NAME} \
	DEBUG=${DEBUG} \
		./deploy.sh

watch-pods:
	kubectl get pods -n ${KEDA_SCALER_NAMESPACE} -w

tail-logs:
	KUBERNETES_NAMESPACE=${KEDA_SCALER_NAMESPACE} \
	HELM_NAME=${HELM_NAME} \
	DEBUG=${DEBUG} \
		./tail_logs.sh

fill-queue:
	cd tools; ./fill_queue_with_messages.sh ${NUMBER_OF_MESSAGES}

create-keda-namespace:
	-kubectl create namespace keda

install-keda: create-keda-namespace remove-keda
	helm repo add kedacore https://kedacore.github.io/charts
	helm repo update
	-kubectl delete secret keda-secrets \
		--namespace=keda
	kubectl create secret generic keda-secrets \
		--namespace=keda \
		--from-literal=awsAccessKeyId=${AWS_ACCESS_KEY_ID} \
		--from-literal=awsSecretAccessKey=${AWS_SECRET_ACCESS_KEY} \
		--from-literal=awsSessionToken=${AWS_SESSION_TOKEN}
	helm install keda kedacore/keda --namespace ${KEDA_NAMESPACE} \
		-f helm/keda-values.yaml

install-helm-git-plugin: remove-helm-git-plugin
	-helm plugin install https://github.com/aslafy-z/helm-git --version 0.10.0

get-keda-scalers-repository: remove-keda-scalers-repository
	helm repo add keda-scalers git+https://github.com/satvidh/keda-scalers@charts?ref=1
	helm repo update

remove-keda-scalers-repository:
	-helm repo remove keda-scalers

remove-keda:
	-kubectl delete secret keda-secrets \
		--namespace=keda
	-helm uninstall -n ${KEDA_NAMESPACE} keda
	-helm repo remove kedacore

remove-helm-git-plugin:
	-helm plugin remove helm-git

install: build install-helm-git-plugin install-keda get-keda-scalers-repository

uninstall: remove-keda-scalers-repository remove-keda remove-helm-git-plugin unbuild

clean: undeploy uninstall
