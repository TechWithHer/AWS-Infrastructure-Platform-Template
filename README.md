# AWS Multi-Environment Infrastructure Platform

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-Provider-2496ED?style=for-the-badge&logo=docker&logoColor=white)

A production-level Infrastructure as Code (IaC) project(70% Replica of a client's project) demonstrating how to provision and manage standardized AWS environments using Terraform modules, CloudFormation bootstrapping, GitHub Actions CI/CD, security scanning, monitoring, and governance controls.

The project follows enterprise DevOps practices including remote state management, infrastructure modularization, deployment approvals, security validation, environment isolation, and operational monitoring.

## Infrastructure Status Dashboard

A single-page dashboard showing dev/stage/prod side by side — CloudWatch alarm status (green/red), tagging compliance %, last deployment timestamp, and resource counts per environment. This directly visualizes the "Governance" and "Monitoring" sections of your README — the parts that are hardest to show in a static screenshot otherwise. Pulls from CloudWatch and Resource Groups Tagging API via a small Lambda + API Gateway backend.

---

## Project Objectives

This project was built to demonstrate:

* Reusable Terraform module design
* Multi-environment infrastructure management
* Remote state storage and locking
* Infrastructure CI/CD automation
* Security and compliance validation
* Monitoring and alerting implementation
* Governance through tagging standards
* Controlled production deployments
* Infrastructure consistency across environments

---

## Architecture Overview

```text
                        GitHub Repository
                                │
                                ▼
                      GitHub Actions CI/CD
                                │
            ┌───────────────────┼───────────────────┐
            │                   │                   │
            ▼                   ▼                   ▼
          Dev                Stage               Prod
            │                   │                   │
            └──────────── Terraform ───────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
      VPC                    EC2/IAM               Lambda
        │                       │
        ▼                       ▼
   CloudWatch Alarms -------> SNS Alerts

                                │
                                ▼
                   S3 Remote State Backend
                                │
                                ▼
                     DynamoDB State Locking
```

---

## Key Features

### Multi-Environment Deployment

The platform supports three isolated environments:

* Development (dev)
* Staging (stage)
* Production (prod)

Each environment:

* Uses independent Terraform state files
* Has environment-specific configurations
* Reuses the same Terraform modules
* Can be deployed independently

---

### Remote State Management

Terraform state is stored centrally in Amazon S3.

Benefits:

* Shared team access
* Versioned state files
* Disaster recovery
* State consistency

Terraform locking is implemented using DynamoDB.

Benefits:

* Prevents concurrent changes
* Eliminates state corruption risks
* Supports collaborative deployments

---

### Infrastructure Modules

Infrastructure is organized into reusable Terraform modules.

#### Networking Module

Creates:

* VPC
* Public Subnets
* Route Tables
* Internet Gateway

#### Compute Module

Creates:

* EC2 Instances
* IAM Roles
* Security Groups

#### Monitoring Module

Creates:

* CloudWatch Alarms
* SNS Topics
* Alert Subscriptions

#### Lambda Module

Creates:

* Lambda Functions
* Execution Roles
* Event Permissions

---

## Repository Structure

```text
.
├── cloudformation/
│   └── backend-bootstrap.yaml
│
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── monitoring/
│   └── lambda/
│
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── scripts/
│   ├── bootstrap.sh
│   └── deploy.sh
│
└── README.md
```

---

## CloudFormation Bootstrap

CloudFormation is used to create Terraform backend resources before Terraform initialization.

Resources created:

* S3 Bucket
* DynamoDB Table

Why CloudFormation?

Terraform requires a backend before state can be stored remotely. Using CloudFormation simplifies the bootstrap process and avoids backend dependency issues.

Resources:

```text
TerraformStateBucket
TerraformLockTable
```

---

## Terraform Backend Configuration

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

Environment-specific state files:

```text
dev/terraform.tfstate
stage/terraform.tfstate
prod/terraform.tfstate
```

---

## Infrastructure Governance

A standardized tagging strategy is applied across all AWS resources.

Example:

```hcl
tags = {
  Project     = "multi-env-platform"
  Environment = "prod"
  ManagedBy   = "Terraform"
  Owner       = "DevOps"
}
```

Benefits:

* Cost tracking
* Resource ownership visibility
* Governance compliance
* Operational consistency

---

## Monitoring and Alerting

CloudWatch monitors infrastructure health and performance.

Examples:

* High CPU Utilization
* Instance Status Check Failures
* Network Errors

CloudWatch Alarms trigger SNS notifications.

Alert Flow:

```text
CloudWatch Alarm
       │
       ▼
   SNS Topic
       │
       ▼
 Email Notification
```

Operational Benefits:

* Faster incident response
* Improved system visibility
* Proactive monitoring

---

## Lambda Automation

AWS Lambda is used for lightweight operational automation.

Example Use Cases:

* Log processing
* Event handling
* Alert remediation
* Scheduled maintenance tasks

Sample Runtime:

```python
def lambda_handler(event, context):
    return {
        "statusCode": 200
    }
```

---

## CI/CD Pipeline

Infrastructure deployments are automated using GitHub Actions.

Pipeline Stages:

```text
Code Push
    │
    ▼
Terraform Format Check
    │
    ▼
Terraform Validate
    │
    ▼
tfsec Scan
    │
    ▼
Trivy Scan
    │
    ▼
Terraform Plan
    │
    ▼
Manual Approval (Prod)
    │
    ▼
Terraform Apply
```

---

## Security Controls

### tfsec

Static analysis for Terraform code.

Checks include:

* Unencrypted resources
* Public access risks
* Security group misconfigurations
* IAM permission issues

### Trivy

Security scanning for:

* Infrastructure misconfigurations
* Dependencies
* Container images
* Vulnerabilities

Benefits:

* Shift-left security
* Early risk detection
* Improved compliance posture

---

## Production Deployment Approval

Production deployments require manual approval through GitHub Environments.

Workflow:

```text
Developer Push
      │
      ▼
Terraform Plan
      │
      ▼
Reviewer Approval
      │
      ▼
Terraform Apply
```

Benefits:

* Change control
* Reduced deployment risk
* Improved governance

---

## Deployment Workflow

### 1. Bootstrap Backend

```bash
aws cloudformation deploy \
  --template-file cloudformation/backend-bootstrap.yaml \
  --stack-name terraform-backend
```

### 2. Initialize Terraform

```bash
cd environments/dev

terraform init
```

### 3. Validate

```bash
terraform validate
```

### 4. Generate Plan

```bash
terraform plan
```

### 5. Apply Changes

```bash
terraform apply
```

---

## Example AWS Resources Created

### Networking

* 1 VPC
* Public Subnets
* Internet Gateway
* Route Tables

### Compute

* EC2 Instances
* IAM Roles
* Security Groups

### Monitoring

* CloudWatch Alarms
* SNS Topics

### Automation

* Lambda Functions

---

## Tech Stack Demonstrated

* Terraform Modules
* Infrastructure as Code (IaC)
* AWS Cloud Architecture
* Remote State Management
* S3 Backend
* DynamoDB Locking
* CloudFormation
* GitHub Actions
* CI/CD Automation
* Security Scanning
* CloudWatch Monitoring
* SNS Alerting
* IAM Governance
* Environment Isolation
* Infrastructure Standardization

---

## Results

* Standardized infrastructure deployment across dev, stage, and prod environments.
* Reduced configuration drift through reusable Terraform modules.
* Improved deployment reliability with automated validation and approvals.
* Increased operational visibility through monitoring and alerting.
* Strengthened security posture through automated scanning and governance controls.

---

## Technology Stack

* Terraform
* AWS CloudFormation
* Amazon EC2
* Amazon VPC
* Amazon IAM
* Amazon S3
* Amazon DynamoDB
* Amazon Lambda
* Amazon CloudWatch
* Amazon SNS
* GitHub Actions
* tfsec
* Trivy
* Python
* Bash

---

## Future Enhancements

* Auto Scaling Groups
* Application Load Balancer
* ECS Fargate
* EKS Integration
* AWS Config Compliance Rules
* AWS Systems Manager
* Cost Optimization Dashboards
* Infrastructure Testing with Terratest
* Multi-Account AWS Architecture

---

## License
MIT
