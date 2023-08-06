import json
import boto3

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    sns_topic_arn = 'arn:aws:sns:us-east-1:<replace-your-account-id>:s3lambdasns' 
    print(event)
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        message = f"File uploaded to bucket: '{bucket_name}', object key: '{object_key}'"
	print(message)

        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject='S3 File Upload Notification'
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent successfully')
    }

