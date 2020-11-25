guard-%:
	@ if [ "${${*}}" = "" ]; then \
        echo "Environment variable $* not set"; \
        exit 1; \
	fi

deploy: guard-QUEUE_NAME guard-AWS_DEFAULT_REGION guard-AWS_ACCESS_KEY_ID guard-AWS_SECRET_ACCESS_KEY guard-AWS_SESSION_TOKEN
	./deploy.sh

watch-pods:
	kubectl get pods -n keda -w

tail-logs:
	kubectl logs -f deployment/keda-aws-sqs-python -n keda

fill-queue:
	cd tools; ./fill_queue_with_messages.sh 50

create-keda-namespace:
	-kubectl create namespace keda

install-keda: create-keda-namespace remove-keda
	helm repo add kedacore https://kedacore.github.io/charts
	helm repo update
	helm install keda kedacore/keda --namespace keda \
		-f helm/values.yaml

install-helm-git-plugin: remove-helm-git-plugin
	-helm plugin install https://github.com/aslafy-z/helm-git --version 0.10.0

get-keda-scalers-repository: remove-keda-scalers-repository
	helm repo add keda-scalers git+https://github.com/satvidh/keda-scalers@charts?ref=1
	helm repo update

remove-keda-scalers-repository:
	-helm repo remove keda-scalers

remove-keda:
	-helm uninstall -n keda keda
	-helm repo remove kedacore

remove-helm-git-plugin:
	-helm plugin remove helm-git

install: install-helm-git-plugin install-keda get-keda-scalers-repository

uninstall: remove-keda-scalers-repository remove-keda remove-helm-git-plugin
