# AWS Multi-Environment Infrastructure Platform

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?style=for-the-badge\&logo=amazonaws\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?style=for-the-badge\&logo=githubactions\&logoColor=white)
![Python](https://img.shields.io/badge/Python-Automation-3776AB?style=for-the-badge\&logo=python\&logoColor=white)

## Overview

The **AWS Multi-Environment Infrastructure Platform** is an enterprise-style Infrastructure as Code (IaC) project that provisions standardized AWS environments using reusable Terraform modules.

The platform demonstrates modern DevOps practices including infrastructure modularization, remote state management, automated CI pipelines, infrastructure security scanning, monitoring, operational automation, governance, and environment isolation.

The objective is to create a reusable infrastructure blueprint that internal engineering teams can use to rapidly provision consistent cloud environments while following infrastructure standards and operational best practices.

---

# Project Objectives

This project demonstrates:

* Enterprise Infrastructure as Code (IaC)
* Multi-environment deployments
* Modular Terraform architecture
* Remote Terraform state management
* Infrastructure CI/CD
* Operational monitoring
* Event-driven automation
* Infrastructure governance
* Standardized tagging
* Automated operational reporting
* Production deployment workflows

---

# Architecture

```text
                          GitHub Repository
                                 │
                                 ▼
                      GitHub Actions CI Pipeline
                                 │
             ┌───────────────────┼───────────────────┐
             │                   │                   │
             ▼                   ▼                   ▼
           Dev                Stage               Production
             │                   │                   │
             └────────────── Terraform ──────────────┘
                                 │
     ┌──────────────┬────────────┼──────────────┬──────────────┐
     │              │            │              │              │
     ▼              ▼            ▼              ▼              ▼
    VPC            EC2          IAM       CloudWatch        Lambda
     │                                         │              │
     │                                         ▼              ▼
     │                                    SNS Alerts     EventBridge
     │
     ▼
S3 Remote Backend + DynamoDB State Locking
```

---

# Project Architecture

The infrastructure is divided into reusable Terraform modules.

```text
modules/
│
├── networking
│      ├── VPC
│      ├── Public Subnets
│      ├── Internet Gateway
│      └── Route Tables
│
├── compute
│      ├── EC2
│      ├── IAM Roles
│      └── Security Groups
│
├── monitoring
│      ├── CloudWatch
│      ├── SNS
│      └── CloudWatch Alarms
│
└── lambda
       ├── Operations Automation
       ├── Health Reporting
       ├── Governance Checks
       ├── Cost Auditing
       └── EventBridge Integration
```

---

# Multi-Environment Infrastructure

The platform supports three isolated environments.

* Development
* Staging
* Production

Each environment maintains:

* Independent Terraform state
* Environment-specific variables
* Shared reusable modules
* Consistent deployment workflow
* Independent lifecycle management

This enables the same infrastructure to be deployed consistently across multiple environments without duplicating code.

---

# Remote State Management

Terraform state is stored remotely using:

* Amazon S3
* Amazon DynamoDB

## S3

Provides:

* Centralized state storage
* Version history
* Team collaboration
* Disaster recovery

## DynamoDB

Provides:

* State locking
* Concurrency protection
* Safe team deployments

---

# CloudFormation Bootstrap

Before Terraform can use a remote backend, the backend itself must exist.

CloudFormation is used to bootstrap:

* Terraform State Bucket
* Terraform Lock Table

This avoids the circular dependency of Terraform attempting to create the backend that it depends on.

---

# Infrastructure Modules

## Networking

Creates:

* VPC
* Internet Gateway
* Route Tables
* Public Subnets
* Route Associations

---

## Compute

Creates:

* EC2 Instances
* IAM Roles
* Instance Profiles
* Security Groups
* User Data Scripts

The EC2 instance automatically installs and starts Nginx using cloud-init, providing a simple web application for infrastructure validation.

---

## Monitoring

Creates:

* CloudWatch Alarms
* SNS Topics
* Email Notifications

Current monitoring includes:

* CPU Utilization
* EC2 Health Checks
* Infrastructure Alerts

CloudWatch alarms notify administrators through SNS whenever predefined thresholds are exceeded.

---

## Operations Automation

The Lambda module serves as the platform's operational automation engine.

Current capabilities include:

* Infrastructure health reporting
* EC2 inventory
* Running vs stopped instance reporting
* Event-driven automation
* Scheduled execution through EventBridge
* Governance validation
* Cost optimization framework
* Operational reporting

The module is intentionally extensible, allowing additional operational tasks to be added without modifying the infrastructure modules.

---

# Event-Driven Operations

Amazon EventBridge schedules operational tasks automatically.

Typical workflow:

```text
EventBridge
      │
      ▼
AWS Lambda
      │
      ▼
Infrastructure Health Report
      │
      ▼
CloudWatch Logs
```

This removes the need for manual operational checks.

---

# Infrastructure Governance

A standardized tagging strategy is applied across all resources.

Example:

```hcl
tags = {
  Project     = "aws-multi-env-platform"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "DevOps"
}
```

Benefits include:

* Cost allocation
* Ownership identification
* Operational consistency
* Governance compliance

---

# CI/CD Pipeline

Infrastructure validation is automated using GitHub Actions.

Pipeline:

```text
Developer Push
        │
        ▼
GitHub Actions
        │
        ▼
Terraform Format Check
        │
        ▼
Terraform Validate
        │
        ▼
Trivy Infrastructure Scan
        │
        ▼
Terraform Plan
        │
        ▼
Plan Artifact
```

The pipeline validates every infrastructure change before deployment.

---

# Infrastructure Security

The project integrates **Trivy** into the CI pipeline to perform Infrastructure-as-Code security scanning.

Checks include:

* Terraform misconfigurations
* Security best-practice violations
* Infrastructure risks
* Configuration weaknesses

Benefits:

* Shift-left security
* Automated infrastructure validation
* Early detection of configuration issues

---

# Deployment Workflow

## Bootstrap Backend

```bash
aws cloudformation deploy \
  --template-file cloudformation/backend-bootstrap.yaml \
  --stack-name terraform-backend
```

---

## Initialize Terraform

```bash
cd environments/dev

terraform init
```

---

## Validate Infrastructure

```bash
terraform fmt

terraform validate
```

---

## Generate Execution Plan

```bash
terraform plan -out=tfplan
```

---

## Apply Infrastructure

```bash
terraform apply tfplan
```

---

# Operational Workflow

```text
Developer
     │
     ▼
Git Push
     │
     ▼
GitHub Actions
     │
     ├── Terraform Format
     ├── Terraform Validate
     ├── Trivy Scan
     └── Terraform Plan
     │
     ▼
AWS Infrastructure
     │
     ├── VPC
     ├── EC2
     ├── CloudWatch
     ├── SNS
     ├── Lambda
     └── EventBridge
     │
     ▼
Scheduled Operational Reports
```

---

# Repository Structure

```text
.
├── cloudformation/
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── monitoring/
│   └── lambda/
│
├── scripts/
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
└── README.md
```

---

# Technologies

* Terraform
* AWS CloudFormation
* Amazon VPC
* Amazon EC2
* Amazon IAM
* Amazon S3
* Amazon DynamoDB
* Amazon CloudWatch
* Amazon SNS
* Amazon EventBridge
* AWS Lambda
* GitHub Actions
* Trivy
* Python
* Bash

---

# Key Outcomes

* Standardized infrastructure deployments
* Modular Terraform architecture
* Automated CI pipeline
* Secure remote Terraform state
* Infrastructure monitoring
* Event-driven operational automation
* Reusable enterprise infrastructure blueprint
* Governance through standardized tagging
* Automated infrastructure validation

---

# Challenges Solved

During development, several real-world engineering challenges were encountered and resolved:

* Migrated Terraform backend after moving to a new AWS account.
* Reconfigured remote state using Amazon S3 and DynamoDB.
* Debugged EC2 user data to automate Nginx installation.
* Validated CloudWatch alarms through CPU stress testing.
* Resolved Lambda deployment failure caused by the reserved `AWS_REGION` environment variable.
* Built an automated GitHub Actions pipeline with infrastructure validation and security scanning.

These challenges mirror common operational scenarios encountered while managing production cloud infrastructure.

---

# Future Enhancements

* Private Subnets
* NAT Gateway
* Application Load Balancer
* Auto Scaling Groups
* ECS/Fargate Deployment
* Amazon EKS
* AWS Config Rules
* AWS Systems Manager
* AWS Organizations
* Multi-Account Architecture
* Infrastructure Testing with Terratest
* Cost Optimization Dashboard
* OIDC Authentication for GitHub Actions
* Production Deployment Approval Gates

---

# License

MIT License
