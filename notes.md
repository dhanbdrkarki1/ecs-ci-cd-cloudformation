For ECS tasks to pull images from ECR, you need three VPC endpoints: [2]

com.amazonaws.region.ecr.api - For ECR API

com.amazonaws.region.ecr.dkr - For ECR Docker Registry

com.amazonaws.region.s3 - For S3 (where ECR stores the actual image layers)