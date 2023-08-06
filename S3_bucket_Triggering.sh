#!/bin/bash

###########################################################################
# Auther  : Vinayak Kesharwani
# Date    : 24 July 2023
# Version : v1
# Purpose : Shell script to trigger uplods/delete's in S3 bucket
###########################################################################


#set in debug mode
set -x

#get aws account id Store the AWS account ID in a variable
aws_account_id=$(aws sts get-caller-identity | jq -r '.UserId'``)

# Print the AWS account ID from the variable
echo "AWS Account ID: $aws_account_id"


# Variables
region="us-east-1"
role_name="s3snslambda"
bucket_name="s3snslambda-bucket"
lambda_function="s3lambdafunction"
email="your-email"  #put your email here

#create an custom iam role for the task to perform 
role_json=$(aws iam create-role \
  --role-name $role_name \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "lambda.amazonaws.com",
                "s3.amazonaws.com",
                "sns.amazonaws.com"
            ]      
        }
      }
    ]
  }'
)

#get roleArn
role_arn=$(echo "$role_json" | jq -r '.Role.Arn')
echo "$role_arn"
# Attach the AmazonSNSFullAccess policy
aws iam attach-role-policy \
  --role-name $role_name \
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess

# Attach the AmazonS3FullAccess policy
aws iam attach-role-policy \
  --role-name $role_name \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Attach the AWSLambdaFullAccess policy
aws iam attach-role-policy \
  --role-name $role_name \
  --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess

#create an s3 bucket using the provisioned resources
aws s3api create-bucket --bucket "$bucket_name" --region "$region"

echo "Bucket created "


# zip the lambda function code
zip -r s3lambdafunction.zip ./s3lambdafunction

#create a lambda function and upload the file to the function
aws lambda create-function \
	--function-name $lambda_function \
	--runtime python3.8 \
	--role "$role_arn" \
	--region "$region" \
	--handler "s3lambdafunction/s3lambdafunction.lambda_handler" \
	--zip-file "fileb://./s3lambdafunction.zip"



echo "lambda function created: $lambda_output"

#add specific permission to s3 for invoking lambda function
aws lambda add-permission \
  --function-name "$lambda_function" \
  --statement-id "s3snslambda" \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --source-arn "arn:aws:s3:::$bucket_name"

#get the lambda fucntion arn
LambdaFunctionArn="arn:aws:lambda:us-east-1:$aws_account_id:function:$lambda_function"

#setup the event trigger
aws s3api put-bucket-notification-configuration   --region "$region"   --bucket "$bucket_name"   --notification-configuration '{
    "LambdaFunctionConfigurations": [{
        "LambdaFunctionArn": "'"$LambdaFunctionArn"'",
        "Events": ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    }]
}'


#create a sns topic
sns_arn=$(aws sns create-topic --name s3lambdasns | jq --raw-output '.TopicArn')

echo "sns topic created: $sns_arn"

#subscribe to the sns service
aws sns subscribe \
	--topic-arn $sns_arn \
	--protocol email \
	--notification-endpoint $email







