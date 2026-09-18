#!/bin/bash

set -e

echo "======================================"
echo " Strenure Infrastructure Destroy"
echo "======================================"

read -p "Enter project name to destroy: " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name cannot be empty."
    exit 1
fi

STATE_KEY="projects/$PROJECT_NAME/terraform_s3_backend.tfstate"

echo ""
echo "Selected project:"
echo "  Project : $PROJECT_NAME"
echo "  State   : $STATE_KEY"
echo ""

echo "Connecting to the project's remote state..."

terraform -chdir=terraform_s3_backend init \
  -reconfigure \
  -backend-config="key=$STATE_KEY"

CURRENT_BUCKET=$(terraform -chdir=terraform_s3_backend output -raw backend_bucket_name)

if [ -z "$CURRENT_BUCKET" ]; then
    echo ""
    echo "Error: No backend bucket found in the selected project's state."
    exit 1
fi

echo ""
echo "Terraform found:"
echo "  Bucket: $CURRENT_BUCKET"
echo ""

EXPECTED_BUCKET=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

if [ "$CURRENT_BUCKET" != "$EXPECTED_BUCKET" ]; then
    echo "ERROR: State does not match the requested project."
    echo ""
    echo "Requested : $EXPECTED_BUCKET"
    echo "Found     : $CURRENT_BUCKET"
    echo ""
    echo "Nothing will be destroyed."
    exit 1
fi

echo "======================================"
echo " WARNING — DESTRUCTIVE OPERATION"
echo "======================================"
echo ""
echo "This will destroy:"
echo "  S3 bucket: $CURRENT_BUCKET"
echo ""
echo "The persistent bootstrap bucket will NOT be destroyed:"
echo "  strenure-infra-template-s3-backend-statefile-bucket"
echo ""

read -p "Type 'yes' to confirm destruction: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "Destruction cancelled."
    exit 0
fi

echo ""
echo "Destroying project backend..."

terraform -chdir=terraform_s3_backend destroy \
  -var="project_name=$PROJECT_NAME"

echo ""
echo "Removing generated backend configuration files..."

rm -f environments/dev/terraform_s3_backend.hcl
rm -f environments/stage/terraform_s3_backend.hcl
rm -f environments/prod/terraform_s3_backend.hcl

echo ""
echo "======================================"
echo " Project Backend Destroyed"
echo "======================================"
echo ""
echo "Project bucket destroyed:"
echo "  $CURRENT_BUCKET"
echo ""
echo "Generated backend configuration files removed."
echo ""
echo "Persistent bootstrap bucket remains untouched:"
echo "  strenure-infra-template-s3-backend-statefile-bucket"
echo ""