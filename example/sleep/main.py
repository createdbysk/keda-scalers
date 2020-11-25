import boto3
import os
import json
import time


def run():
    print('Watching for messages')
    sqs = boto3.resource('sqs')
    queue_name = os.environ.get("QUEUE_NAME", "keda-test")
    queue = sqs.get_queue_by_name(QueueName=queue_name)

    while True:
        print('Checking for messages in queue')
        for message in queue.receive_messages(WaitTimeSeconds=20):
            try:
                print(f"Message from queue {message.body}")
                payload = json.loads(message.body)
                print(
                    f"Handle Message {payload['message_number']}. \n"
                    f"Will sleep for {payload['sleep_seconds']} seconds."
                )
                time.sleep(payload['sleep_seconds'])
                print(
                    f"Done Message {payload['message_number']}. \n"
                    f"Slept for {payload['sleep_seconds']}"
                )
            except Exception as e:
                print(
                    f"Message {message.body}"
                    f" caused an exception {e}. \n"
                )
            finally:
                message.delete()


if __name__ == '__main__':
    run()
