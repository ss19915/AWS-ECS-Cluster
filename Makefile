include .env

ECS_STACK_NAME=${STACK_NAME}-Ecs
TASK_STACK_NAME=${STACK_NAME}-Task

deploy:
	@aws cloudformation deploy \
		--region us-east-1 \
		--template-file cloudFormationTemplates/ecsCluster.yaml \
		--no-fail-on-empty-changeset \
		--capabilities CAPABILITY_IAM \
		--stack-name ${ECS_STACK_NAME} \
		--parameter-overrides \
			VpcId=${VPC_ID} \
			$$([ "${ENVIRONMENT}" == '' ] || echo "Environment=${ENVIRONMENT}" ) \
			KeyName=${KEY_NAME} \
			EcsClusterName=${ECS_CLUSTER_NAME} \
			UserName=${USER_NAME}

delete:
	@aws cloudformation delete-stack \
		--stack-name ${ECS_STACK_NAME}

createTask:
	@aws cloudformation deploy \
		--region us-east-1 \
		--template-file cloudFormationTemplates/ecsTask.yaml \
		--no-fail-on-empty-changeset \
		--capabilities CAPABILITY_IAM \
		--stack-name ${TASK_STACK_NAME}

deleteTask:
	@aws cloudformation delete-stack \
		--stack-name ${TASK_STACK_NAME}
