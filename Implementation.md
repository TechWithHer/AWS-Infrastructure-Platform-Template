# Project Implementation and Modification Document

## Why I created this project?

I identified a repeatable infrastructure-provisioning problem and designed a reusable Terraform framework to standardize provisioning, state management, environment separation, security controls and operational workflows.

## About the Project: 

Designed and implemented a reusable Terraform-based AWS infrastructure framework with modular networking, compute, monitoring, and Lambda components, environment isolation, centralized S3 remote state with locking and versioning, and automated project bootstrap/cleanup workflows.

The objective is to create a reusable infrastructure blueprint that internal engineering teams can use to rapidly provision consistent cloud environments while following infrastructure standards and operational best practices.


#### Common Issues Resolved:

- *Inconsistent resource naming*
Standardized AWS resource naming using project and environment conventions.

- *Poor infrastructure state management*
Centralized Terraform state in Amazon S3 with state locking and versioning to improve consistency, traceability, and recovery.

- *Manual provisioning and configuration errors*
Automated infrastructure provisioning through reusable Terraform modules and bootstrap scripts, reducing repetitive manual work and configuration drift.

- *Uncontrolled infrastructure access*
Designed the platform to use IAM-based access controls so only authorized users can provision, modify, or access infrastructure and Terraform state.

- S3 backend security controls implemented, with IAM-based access control planned for authorized infrastructure operations and state access.

### Project Flow 

````text

New project starts
       ↓
User clones template
       ↓
User RUNS -> bash setup.sh
       ↓
User provides project name, eg : my-project-123
       ↓
Terraform creates project-specific infrastructure
       ↓
Same template can be reused for Project A, B, C, D...

````
## Step 1: Creation of Backend

(Old Version : 25.05.2025) 
Created Cloudformation stack for backend and state locking. This stack included S3 Bucket + DynamoDB (for statelocking). 
For each environment there were separate bucket keys: 
- dev/terraform.tfstate
- stage/terraform.tfstate
- prod/terraform.tfstate 

#### Updated: Dynamo DB depreciated and replaced by S3 native locking

(New Version : 29.08.2025) 
S3 bucket was used for is for storing the tfstate files of different environments along with S3-native locking(Replaced by Dynamo DB). 

Only one S3 Bucket created with 3 keys for different environments as mentioned above.

### Important Learning: 

We cannot use the S3-native locking while creating the S3 bucket. We can add standard s3 attributes like: versioning + encryption + public-access blocking + TLS-only acces etc. 

**S3-native locking is a Terraform backend feature. It is enabled when Terraform stores state in an existing S3 bucket; it is not an attribute used while creating the S3 bucket itself.**

So: 
- use_lockfile = true 
belongs to the Terraform S3 backend configuration, not the aws_s3_bucket resource.

### Architechture

````text
         backup of the backend, 
          created manually on aws console
                 │
                 ▼
              backend/
                 │
                 ▼
       ┌───────────────────┐
       │ S3 Bucket          │
       │ Encryption         │
       │ Versioning         │
       │ Public access off  │
       │ TLS enforcement    │
       └─────────┬─────────┘
                 │
        Terraform backend
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
      Dev      Stage      Prod
       │         │         │
    state       state      state
    + lock      + lock     + lock

````

#### Bucket Security Setup

````text

                    S3 Bucket
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
    Versioning     Encryption    Public Access
        │              │              │
        └──────────────┼──────────────┘
                       ↓
                 Bucket Policy
                       │
                  HTTPS only
                       │
                       ▼
             Terraform State

````
------------------------------------------------------------------
## Step 2: Making the Project - Template Specific. 

The main intention in this project is - resuablility. 

The user need to input the project name and then this project name propogates accross 2 different terraform folders.

We have added a file terraform.tfvars.example for reference. 

While using this project simply cp the code and update the project name and other information accordingly. 

````code
cp terraform.tfvars.example terraform.tfvars
````

Simply putting: 
````
Clone → configure project name → initialize → deploy.
````
Note: This step enhances the reusability of the project. The .example file is documentation + a starting point. The real .tfvars file is the project's actual input.

#### Not pushing the .tfvars to GitHub.

For project_name, there is nothing sensitive about the value itself. But keeping terraform.tfvars ignored is still a common and useful convention because later we may put things like account-specific IDs, credentials-related values, or other environment-specific configuration there.

#### Created an Output.tf to display the list of resources created 
------------------------------------------------------------------
## Step 3: The Initialization Mechanism

Created setup.sh at the repository root.So the user enters the project name once.setup.sh automatically generates the three backend files

It takes the bucket name returned by Terraform and creates:

environments/dev/terraform_s3_backend.hcl
environments/stage/terraform_s3_backend.hcl
environments/prod/terraform_s3_backend.hcl

with the appropriate environment-specific key.


````
terraform_s3_backend/
     │
     │ creates
     ▼
ayu-sonal-bucket
     │
     │ value must be passed to Dev
     ▼
environments/dev/
     │
     └── terraform_s3_backend.hcl
             bucket = "ayu-sonal-bucket"
             key    = "dev/terraform.tfstate"

````
````
                    USER
                      │
             enters project name
                      │
                      ▼
             terraform_s3_backend
                      │
                creates bucket
                      │
                      ▼
              bucket name known
                      │
                      ▼
        generate/update backend config
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
        dev.hcl    stage.hcl    prod.hcl
          │           │           │
          ▼           ▼           ▼
      terraform init for each environment

````

bootstrap script/mechanism is what connects Part 1 and Part 2.

````
./setup.sh
   ↓
"Enter project name:"
   ↓
ayu-sonal-bucket
   ↓
terraform_s3_backend
   ↓
S3 bucket created
   ↓
generate backend configs
   ↓
dev/terraform_s3_backend.hcl
stage/terraform_s3_backend.hcl
prod/terraform_s3_backend.hcl

````

## Step 4: Created a persistent bootstrap S3 bucket manually

strenure-infra-template-s3-backend-statefile-bucket

It is a persistent platform resource whose lifecycle is managed separately from the project Terraform configuration.
Its job is to store the Terraform state of the terraform_s3_backend project itself.

````
Persistent bootstrap bucket
strenure-infra-template-s3-backend-statefile-bucket
        │
        └── terraform_s3_backend/terraform.tfstate


Project state bucket
<project-name>
        │
        ├── dev/terraform.tfstate
        ├── stage/terraform.tfstate
        └── prod/terraform.tfstate

````

------------------------------------------------------------------
## Step 5: multi-project state isolation


-------------------------------------------------------------------
## Setup 6: Setting up and testing Dev



✅ Dev backend is initialized successfully.
✅ Dev state is being handled by the S3 backend.
✅ Terraform can read the Dev state.
-------------------------------------------------------------------
## Step 7 setting up modules 


## Step 7a: VPC Setup

VPC
├── 2 Public Subnets
├── 2 Private Subnets
├── Internet Gateway
├── Public Route Table
├── Private Route Table
├── Public route associations
└── Private route associations


-------------------------------------------------------------------
                  Developer
                      │
                      ▼
              Clone Platform Repo
                      │
                      ▼
          Select Environment (dev/stage/prod)
                      │
                      ▼
         Configure Variables (.tfvars)
                      │
                      ▼
               Git Push / Pull Request
                      │
                      ▼
           GitHub Actions CI Pipeline
      ┌──────────┬──────────┬──────────┐
      ▼          ▼          ▼
 terraform fmt  validate   security scans
                              │
                              ▼
                      terraform plan
                              │
                 (Review / Approval)
                              ▼
                     terraform apply
                              │
                              ▼
                  Terraform provisions AWS
      ┌──────────────┬──────────────┬──────────────┐
      ▼              ▼              ▼
     VPC           EC2/IAM     Monitoring
                                      │
                                      ▼
                          CloudWatch + SNS
                                      │
                                      ▼
                         Operations Lambda
                                      │
                                      ▼
                    Health Checks / Audits / Reports

## Version 1: Building basic blocks

Creating the Project Structure.
- Creating the working environment (local setup and .gitignore)
- Modules and Environment [prod, dev, staging]
- Copying the docker project here : [Project Repo](https://github.com/TechWithHer/Multi-Environment-Web-Service-with-Terraform)
- TEST THE PROJECT ON AWS EC2 with DOCKER



## Final Architecture

```text
GitHub Repository
│
├── modules/
│   ├── networking/
│   │    ├── VPC
│   │    ├── Public Subnets
│   │    ├── Internet Gateway
│   │    └── Route Tables
│   │
│   ├── compute/
│   │    ├── EC2
│   │    ├── IAM Role
│   │    └── Security Groups
│   │
│   ├── monitoring/
│   │    ├── CloudWatch Alarms
│   │    └── SNS Notifications
│   │
│   └── lambda/
│        └── Lambda Function
│
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── cloudformation/
│   └── backend-bootstrap.yaml
│
├── .github/workflows/
│   └── terraform.yml
│
└── README.md
```

---

# Phase 1: Bootstrap Infrastructure (CloudFormation)

This is where CloudFormation comes in.

Terraform cannot safely create its own remote backend before using it.

So create:

```text
S3 Bucket
DynamoDB Table
```

using CloudFormation.

### backend-bootstrap.yaml

Creates:

```text
terraform-state-bucket
terraform-lock-table
```

Resources:

```yaml
Resources:

  TerraformStateBucket:
    Type: AWS::S3::Bucket

  TerraformLockTable:
    Type: AWS::DynamoDB::Table
```

Interview explanation:

> CloudFormation bootstraps Terraform backend resources because Terraform cannot reliably manage its own state backend initialization.

This is a very common enterprise pattern.

---

# Phase 2: Configure Terraform Remote State

Instead of:

```hcl
terraform {
  backend "local" {}
}
```

Use:

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

For prod:

```hcl
key = "prod/terraform.tfstate"
```

For stage:

```hcl
key = "stage/terraform.tfstate"
```

Now each environment has:

```text
Separate State
Shared Backend
State Locking
```

---

# Phase 3: Multi-Environment Structure

```text
environments/

├── dev
├── stage
└── prod
```

Each environment:

```hcl
module "networking" {
  source = "../../modules/networking"
}

module "compute" {
  source = "../../modules/compute"
}

module "monitoring" {
  source = "../../modules/monitoring"
}
```

Same modules.

Different variables.

---

# Phase 4: Networking Module

Create:

```text
modules/networking
```

Resources:

```text
VPC
Subnets
Internet Gateway
Route Tables
```

Terraform:

```hcl
resource "aws_vpc" "this"
resource "aws_subnet" "public"
resource "aws_internet_gateway" "this"
resource "aws_route_table" "this"
```

Interview point:

> Reusable VPC module consumed by all environments.

---

# Phase 5: Compute Module

Create:

```text
modules/compute
```

Resources:

```text
EC2
IAM Role
Security Group
```

Terraform:

```hcl
resource "aws_instance" "web"
resource "aws_iam_role" "ec2_role"
resource "aws_security_group" "web_sg"
```

User Data:

```bash
#!/bin/bash

yum update -y

yum install nginx -y

systemctl start nginx

systemctl enable nginx
```

EC2 automatically hosts webpage.

---

# Phase 6: Tagging Governance

Create:

```hcl
locals {

 common_tags = {
   Project     = "multi-env-platform"
   ManagedBy   = "Terraform"
   Owner       = "DevOps"
   Environment = var.environment
 }
}
```

Every resource:

```hcl
tags = local.common_tags
```

Interview answer:

> Governance enforced through centralized tagging strategy.

---

# Phase 7: CloudWatch Monitoring

Monitoring module:

```text
modules/monitoring
```

Create:

```hcl
resource "aws_cloudwatch_metric_alarm"
```

Example:

```text
CPU > 80%
```

Alarm:

```hcl
comparison_operator = "GreaterThanThreshold"

threshold = 80
```

---

# Phase 8: SNS Notifications

Create:

```hcl
resource "aws_sns_topic" "alerts"
```

Connect:

```hcl
alarm_actions = [
 aws_sns_topic.alerts.arn
]
```

Flow:

```text
EC2 High CPU
        ↓
CloudWatch Alarm
        ↓
SNS
        ↓
Email Notification
```

This directly supports:

> CloudWatch monitoring and SNS alerts.

---

# Phase 9: Lambda Automation

Create:

```text
modules/lambda
```

Python:

```python
import json

def lambda_handler(event, context):

    print(event)

    return {
        "statusCode": 200
    }
```

Terraform:

```hcl
resource "aws_lambda_function"
```

Possible use cases:

```text
Auto-remediation
Log processing
Alarm handling
```

---

# Phase 10: GitHub Actions CI/CD

```text
.github/workflows/terraform.yml
```

Pipeline:

```text
Push
 ↓
fmt
 ↓
validate
 ↓
tfsec
 ↓
plan
 ↓
approval
 ↓
apply
```

Example:

```yaml
jobs:

  validate:

  security:

  plan:

  apply:
```

---

# Phase 11: tfsec Security Scan

Add:

```yaml
- name: tfsec
  uses: aquasecurity/tfsec-action
```

Checks:

```text
Open Security Groups
Unencrypted S3 Buckets
IAM Risks
```

Supports CV bullet:

> Integrated security scanning

---

# Phase 12: Trivy Scan

Add:

```yaml
- name: Trivy
```

Scans:

```text
Terraform Misconfigurations
Dependencies
Containers
```

Supports:

> Integrated security scanning (Trivy)

---

# Phase 13: Production Approval

GitHub Environment:

```text
dev
stage
prod
```

Configure:

```text
prod
 ↓
Required Reviewer
```

Workflow:

```yaml
environment: prod
```

Flow:

```text
Developer
    ↓
Plan
    ↓
Approval
    ↓
Apply
```

Supports:

> Controlled production deployment approvals.

---

# Phase 14: Documentation

README sections:

```text
Architecture
Terraform Modules
Backend Design
CI/CD Workflow
Security Controls
Monitoring
Deployment Process
```

Add architecture diagram:

```text
GitHub
   ↓
GitHub Actions
   ↓
Terraform
   ↓
AWS

 ├─ VPC
 ├─ EC2
 ├─ IAM
 ├─ CloudWatch
 ├─ SNS
 ├─ Lambda

Remote State
 ├─ S3
 └─ DynamoDB
```

---

## End Result

After implementing these components, your CV statement becomes fully defensible:

✅ Terraform Modules
✅ Multi-environment (dev/stage/prod)
✅ S3 Remote State
✅ DynamoDB Locking
✅ CloudFormation Bootstrap
✅ GitHub Actions CI/CD
✅ tfsec Security Scanning
✅ Trivy Security Scanning
✅ IAM Governance
✅ CloudWatch Monitoring
✅ SNS Alerts
✅ Lambda Automation
✅ Production Approval Gates
✅ Tagging Strategy

