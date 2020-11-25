import boto3
import os
import json
import time
import logging


log_level = os.environ.get("LOG_LEVL", "INFO")
logging.basicConfig(level=log_level)
root_logger = logging.getLogger()
root_logger.setLevel(log_level)
node_name = os.environ.get("NODE_NAME", "node-name-not-found")
logger = logging.getLogger(node_name)


def run():
    logger.info('Watching for messages')
    sqs = boto3.resource('sqs')
    queue_name = os.environ.get("QUEUE_NAME", "keda-test")
    queue = sqs.get_queue_by_name(QueueName=queue_name)

    while True:
        logger.info('Checking for messages in queue')
        for message in queue.receive_messages(WaitTimeSeconds=20):
            try:
                logger.info(f"Message from queue {message.body}")
                payload = json.loads(message.body)
                sleep_seconds = payload['sleep_seconds']
                logger.info(
                    f"Handle Message {payload['message_number']}. \n"
                    f"Will sleep for {sleep_seconds} seconds."
                )
                visibility_timeout = sleep_seconds + 10
                message.change_visibility(VisibilityTimeout=visibility_timeout)
                logger.info(
                    f"Message will not be visible for about"
                    f" {visibility_timeout} seconds."
                )
                time.sleep(payload['sleep_seconds'])
                logger.info(
                    f"Done Message {payload['message_number']}. \n"
                    f"Slept for {sleep_seconds}"
                )
            except Exception as e:
                logger.error(
                    f"Message {message.body}"
                    f" caused an exception {e}. \n"
                )
            finally:
                message.delete()


if __name__ == '__main__':
    run()
