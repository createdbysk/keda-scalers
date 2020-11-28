KEDA_NAMESPACE=keda
KEDA_SCALER_NAMESPACE=keda-scaler
HELM_NAME=keda-aws-sqs-queue-scaler
CHARTS_PATH=../../charts
DOCKER_IMAGE=satvidh/keda-aws-sqs-queue-scaler-example-sleep:1.0.0

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
	-docker rmi $(DOCKER_IMAGE)

build:
	docker build . -t $(DOCKER_IMAGE)
	# TODO: Implement image push into Minikube/Kind.

deploy: guard-QUEUE_NAME guard-AWS_DEFAULT_REGION guard-AWS_ACCESS_KEY_ID guard-AWS_SECRET_ACCESS_KEY guard-AWS_SESSION_TOKEN
	KUBERNETES_NAMESPACE=${KEDA_SCALER_NAMESPACE} \
	HELM_NAME=${HELM_NAME} \
	CHARTS_PATH=${CHARTS_PATH} \
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

add-keda-scalers-namespace: delete-keda-scalers-namespace
	kubectl create namespace keda-scalers

delete-keda-scalers-namespace:
	-kubectl delete namespace keda-scalers

remove-keda:
	-kubectl delete secret keda-secrets \
		--namespace=keda
	-helm uninstall -n ${KEDA_NAMESPACE} keda
	-helm repo remove kedacore

remove-helm-git-plugin:
	-helm plugin remove helm-git

install: install-helm-git-plugin install-keda add-keda-scalers-namespace

uninstall: delete-keda-scalers-namespace remove-keda remove-helm-git-plugin

clean: undeploy uninstall
