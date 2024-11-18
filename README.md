# ECS CI/CD Pipeline with CloudFormation

This project sets up a complete CI/CD pipeline for deploying applications to Amazon ECS using AWS CloudFormation. The pipeline uses CodePipeline, CodeBuild, and ECR to build and deploy Docker containers.

## Architecture

![Architecture Diagram](architecture.png)

The solution includes:
- AWS CodePipeline for CI/CD orchestration
- AWS CodeBuild for building Docker images
- Amazon ECR for container image storage
- Amazon ECS for container orchestration
- GitHub as the source code repository
- AWS CloudFormation for infrastructure as code


## Prerequisites

1. AWS CLI installed and configured
2. GitHub repository with your application code
3. AWS CodeStar connection to GitHub
4. Docker installed (for local testing)
5. Node.js installed (for local testing)

## Project Structure
├── README.md
├── cicd.yaml # CloudFormation template for CI/CD pipeline
├── params.json # Parameters for CloudFormation stack
├── buildspec.yml # Build specifications for CodeBuild
├── Dockerfile # Docker image definition
├── package.json # Node.js application dependencies
├── index.js # Sample application code
└── .gitignore # Git ignore file


## Deployment Steps

### 1. Create GitHub Connection

1. Go to AWS Console → Developer Tools → Settings → Connections
2. Click "Create connection"
3. Select "GitHub" and follow the authorization process
4. Copy the connection ID (you'll need it for params.json)

### 2. Configure Parameters

Update `params.json` with your values:

```json
[
    {
        "ParameterKey": "Environment",
        "ParameterValue": "dev"
    },
    {
        "ParameterKey": "ProjectName",
        "ParameterValue": "ecs-demo-app"
    },
    {
        "ParameterKey": "EcsClusterName",
        "ParameterValue": "ecs-demo-app-cluster"
    },
    {
        "ParameterKey": "EcsServiceName",
        "ParameterValue": "ecs-demo-app-service"
    },
    {
        "ParameterKey": "GitHubRepoId",
        "ParameterValue": "your-github-username/your-repo-name"
    },
    {
        "ParameterKey": "GitHubBranch",
        "ParameterValue": "main"
    },
    {
        "ParameterKey": "CodeStarConnectionName",
        "ParameterValue": "your-connection-id"
    },
    {
        "ParameterKey": "EcsContainerName",
        "ParameterValue": "ecs-demo-app"
    }
]
```

### 3. Deploying the Pipeline
```
# Create the stack
aws cloudformation create-stack \
  --stack-name ecs-demo-cicd \
  --template-body file://cicd.yaml \
  --parameters file://params.json \
  --capabilities CAPABILITY_IAM

# Monitor stack creation
aws cloudformation describe-stacks \
  --stack-name ecs-demo-cicd \
  --query 'Stacks[0].StackStatus'
```

aws cloudformation create-stack   --stack-name ecs-infra   --template-body file://ecs-cluster.yaml   --parameters file://params.json   --capabilities CAPABILITY_IAM

aws cloudformation create-stack   --stack-name ecs-demo-cicd   --template-body file://cicd.yaml   --parameters file://params.json   --capabilities CAPABILITY_IAM

aws cloudformation delete-stack --stack-name ecs-demo-app-cluster

aws cloudformation delete-stack --stack-name ecs-demo-app-cluster

## Local Testing
1. Build the Docker image locally:
```
docker build -t ecs-demo-app .
```

2. Run the container:
```
docker run -p 3000:3000 ecs-demo-app
```

3. Test the application:
```
curl http://localhost:3000
```

# Cleanup
To delete all resources:
```
# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name ecs-demo-cicd

# Monitor stack deletion
aws cloudformation describe-stacks \
  --stack-name ecs-demo-cicd \
  --query 'Stacks[0].StackStatus'
```

## Security Considerations
- All S3 buckets have encryption enabled
- Public access is blocked on S3 buckets
- IAM roles follow least privilege principle
- ECR repository has image scanning enabled
- Secure connections used throughout the pipeline

## Troubleshooting
1. Pipeline Failures
- Check CodeBuild logs for detailed error messages
- Verify GitHub connection status
- Ensure IAM roles have correct permissions

2. Build Issues
- Validate buildspec.yml syntax
- Check Dockerfile for errors
- Verify ECR repository exists

3. Deployment Issues
- Check ECS service status
- Verify task definition
- Review container logs