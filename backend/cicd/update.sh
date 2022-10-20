#! /bin/bash

# TASK_DEFINITION = "ecsprac-td"
# AWS_REGION = "ap-southeast-2"
# ECR_REPO_NAME = "ecsprac"
# IMAGE_TAG = "${GIT_COMMIT[0..5]}"
# IMAGE_URI = "${AWS_ACCOUNTID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
# TASK_DEFINITION = "ecsprac-td"

# TASK_DEF = (aws ecs describe-task-definition — task-definition ${TASK_DEFINITION} — region=${AWS_REGION})

# echo ${TASK_DEF} | jq '.containerDefinitions[0].image='\"${IMAGE_URI}\" \ > task-def.json

# aws ecs register-task-definition — family ${TASK_DEFINITION} — region=${AWS_REGION} — cli-input-json file://task-def.json# 

# CTRL+/

TASK_NAME = "ecsprac-td"
SERVICE_NAM E ="ecsprac-service"
IMAGE_NAME = "prac"
CLUSTER_NAME = "ecsprac-cluster"
REGION = "ap-southeast-2"
VERSION = "latest"
ACCOUNT_NUMBER = "327746137438"

NEW_IMAGE=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:$VERSION
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_NAME" --region "$REGION")
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$NEW_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
NEW_REVISION=$(aws ecs register-task-definition --region "$REGION" --cli-input-json "$NEW_TASK_DEFINITION")
NEW_REVISION_DATA=$(echo $NEW_REVISION | jq '.taskDefinition.revision')

NEW_SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_NAME --force-new-deployment)

echo "done"
echo "${TASK_NAME}, Revision: ${NEW_REVISION_DATA}"
