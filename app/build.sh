#!/usr/bin/env bash
set -e

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_REPO="$AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/flask-app"
export HASH=$(git rev-parse --short HEAD)
export WORK_DIR=$(dirname $0)

docker build --tag "$ECR_REPO:$HASH" $WORK_DIR
docker push "$ECR_REPO:$HASH"
