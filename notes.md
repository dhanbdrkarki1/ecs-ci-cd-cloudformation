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


## Deployment Configuration
```
ECSService:
  Type: AWS::ECS::Service
  Properties:
    # ... other properties ...
    DesiredCount: 2
    DeploymentConfiguration:
      MaximumPercent: 200      # This allows up to double the desired count during deployment
      MinimumHealthyPercent: 100   # This ensures no tasks are stopped until new ones are healthy
```

When MaximumPercent is set to 200, during a deployment ECS is allowed to run up to twice the desired count of tasks temporarily. This means:
1. Your desired count is 2
2. During deployment, ECS will start 2 new tasks (with the new version)
3. The old 2 tasks keep running until the new tasks are healthy
4. So temporarily you'll see 4 tasks (2 old + 2 new)

