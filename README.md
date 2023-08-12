# Aws_s3-bucket_triggerring

This repository contains a shell script that creates an AWS Lambda function and an SNS topic, and then configures the Lambda function to be triggered by events in an S3 bucket. When an object is created or deleted in the S3 bucket, the Lambda function will be invoked and will publish a notification to the SNS topic. The notification will be sent to the email address specified in the code.

## Requirements

* AWS CLI
* Python 3

## Setup

1. Clone the repository
2. Set up the AWS CLI with `aws confige` command
   you will be needing your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to configure the cli locally.
3. Run the following command to create the resources:`./S3_bucket_Triggering.sh`

## Configuration

The Lambda function is configured to be triggered by events in the S3 bucket named `s3lambdasns-bucket`. To change the bucket name, edit the `S3_bucket_Triggering.sh` script.

The SNS topic is named `s3lambdasns`. To change the topic name, edit the `S3_bucket_Triggering.sh` script.

The email address that will receive notifications is specified in the `S3_bucket_Triggering.sh` script. To change the email address, edit the `S3_bucket_Triggering.sh` script.

## Testing

To test the Lambda function, upload a file to the S3 bucket. The Lambda function will be invoked and will publish a notification to the SNS topic. You should receive an email with the notification.

I hope this is helful!
