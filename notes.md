For ECS tasks to pull images from ECR, you need three VPC endpoints:
- com.amazonaws.region.ecr.api - For ECR API
- com.amazonaws.region.ecr.dkr - For ECR Docker Registry
- com.amazonaws.region.s3 - For S3 (where ECR stores the actual image layers)


## ECSExecutionRole (Required):
- Used by the ECS agent to pull container images
- Access ECR repositories
- Write container logs to CloudWatch
- Pull secrets from Secrets Manager/SSM Parameter Store

## ECSApplicationTaskRole (Optional):
- Used by your application code running inside the container
- Only needed if your application needs to interact with AWS services

### Examples of when you'd need it:
- Application needs to access S3 buckets
- Application needs to write to DynamoDB
- Application needs to send messages to SQS
- Application needs to access other AWS services