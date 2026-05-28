# This file documents the S3 backend that must be created BEFORE terraform init
# Run the commands below manually once, then terraform init will use it

# aws s3api create-bucket \
#   --bucket devops-final-tfstate-ubaid \
#   --region ap-south-1 \
#   --create-bucket-configuration LocationConstraint=ap-south-1

# aws s3api put-bucket-versioning \
#   --bucket devops-final-tfstate-ubaid \
#   --versioning-configuration Status=Enabled

# aws dynamodb create-table \
#   --table-name terraform-lock-ubaid \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region ap-south-1
