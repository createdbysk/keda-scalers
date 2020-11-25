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
        for message in queue.receive_messages(WaitTimeSeconds=20):
            print(f"Message from queue {message.body}")
            payload = json.loads(message.body)
            print(
                f"Handle Message {payload.message_number}. \n"
                f"Will sleep for {payload.sleep_seconds}"
            )
            time.sleep(payload.sleep_seconds)
            print(
                f"Done Message {payload.message_number}. \n"
                f"Slept for {payload.sleep_seconds}"
            )
            message.delete()


if __name__ == '__main__':
    run()
