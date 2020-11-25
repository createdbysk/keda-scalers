# keda-aws-sqs-queue-scaler

Provides helm charts for KEDA AWS SQS queue scaler

## Usage

Learn how to use the chart through the example(s) below.

### example/sleep

        cd example/sleep

* Install KEDA

        make install

* Build the example

        make build

* Deploy the example

        make deploy

* Watch the action
  * In a terminal window, watch pods come and go

            make watch-pods

  * In another terminal window, watch logs.
    * Install [stern](https://github.com/wercker/stern)

            make tail-logs

## Troubleshoot issues

* If KEDA will not scale the containers even if there are messages in the queue
  * If you deployed locally with `operator` credentials, ensure that `keda-operator` deployment has valid AWS credentials.
    * Run the command below to look at the operator logs

            kubectl logs -f deployment/keda-operator -n keda

    Look for any errors reported in those logs.

## Acknowledgement

* The helm chart is based on the manifest in https://github.com/patnaikshekhar/KEDA-AWS-SQS-Python. 
* The example is based on the code in https://github.com/patnaikshekhar/KEDA-AWS-SQS-Python