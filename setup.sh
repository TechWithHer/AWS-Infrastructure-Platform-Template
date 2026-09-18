#!/bin/bash

set -e

echo "======================================"
echo " Strenure Infrastructure Setup"
echo "======================================"

read -p "Enter project name: " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name cannot be empty."
    exit 1
fi

echo ""
echo "Creating project backend: $PROJECT_NAME"
echo ""

STATE_KEY="projects/$PROJECT_NAME/terraform_s3_backend.tfstate"

terraform -chdir=terraform_s3_backend init \
  -reconfigure \
  -backend-config="key=$STATE_KEY"

terraform -chdir=terraform_s3_backend apply \
  -var="project_name=$PROJECT_NAME"

BUCKET_NAME=$(terraform -chdir=terraform_s3_backend output -raw backend_bucket_name)

echo ""
echo "Backend bucket created: $BUCKET_NAME"
echo ""

cat > environments/dev/terraform_s3_backend.hcl <<EOF
bucket       = "$BUCKET_NAME"
key          = "dev/terraform.tfstate"
region       = "ap-southeast-1"
use_lockfile = true
EOF

cat > environments/stage/terraform_s3_backend.hcl <<EOF
bucket       = "$BUCKET_NAME"
key          = "stage/terraform.tfstate"
region       = "ap-southeast-1"
use_lockfile = true
EOF

cat > environments/prod/terraform_s3_backend.hcl <<EOF
bucket       = "$BUCKET_NAME"
key          = "prod/terraform.tfstate"
region       = "ap-southeast-1"
use_lockfile = true
EOF

echo "Backend configuration generated:"
echo "  Dev   → environments/dev/terraform_s3_backend.hcl"
echo "  Stage → environments/stage/terraform_s3_backend.hcl"
echo "  Prod  → environments/prod/terraform_s3_backend.hcl"