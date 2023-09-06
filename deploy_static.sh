#!/bin/bash

cd "infrastructure/modules" || exit

# Get the bucket name from the Terraform output
BUCKET_NAME=$(terraform output -json | jq -r '.next_bucket_name.value')

# Check if the bucket name is empty
if [ -z "$BUCKET_NAME" ]; then
  echo "Failed to retrieve the bucket name from Terraform output."
  exit 1
fi

echo "Bucket name: $BUCKET_NAME"


cd "/workspaces/next-js-app" || exit

# Define your container image and name
CONTAINER_IMAGE="055531036085.dkr.ecr.eu-west-1.amazonaws.com/next-js-app-builder:latest"
CONTAINER_NAME="next-js-builder"

# Start the Docker container
docker run -d --name "$CONTAINER_NAME" "$CONTAINER_IMAGE"

# Wait for the container to complete its work (you can adjust the sleep time)
sleep 10

# Copy files from the container to the local directory
mkdir -p ./tmp/public
mkdir -p ./tmp/.next/static

docker cp "$CONTAINER_NAME:/app/.next/static" "./tmp/.next"
docker cp "$CONTAINER_NAME:/app/public" "./tmp/public"

# Use AWS CLI to upload files to S3
aws s3 cp ./tmp/.next/static/ "s3://$BUCKET_NAME/_next/static" --recursive
aws s3 cp ./tmp/public "s3://$BUCKET_NAME/public" --recursive

# Remove the directory and all its contents
rm -rf ./tmp

# Stop and remove the Docker container
docker stop "$CONTAINER_NAME"
docker rm "$CONTAINER_NAME"

echo "Files copied from container and uploaded to S3."