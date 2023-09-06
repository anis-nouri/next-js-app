#!/bin/bash

cd "infrastructure/modules/aws-lambda-web-adapter" || exit

# Get the bucket name from the Terraform output
BUCKET_NAME=$(terraform output -json | jq -r '.next_bucket_name.value')

# Check if the bucket name is empty
if [ -z "$BUCKET_NAME" ]; then
  echo "Failed to retrieve the bucket name from Terraform output."
  exit 1
fi

echo "Bucket name: $BUCKET_NAME"


# Copy .next/static/ directory
aws s3 cp ../../../.next/static/ "s3://$BUCKET_NAME/_next/static" --recursive

# Copy public directory
aws s3 cp ../../../public "s3://$BUCKET_NAME/public" --recursive

echo "File copy completed successfully."
