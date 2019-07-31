include .env
deploy:
	@aws cloudformation deploy \
		--region us-east-1 \
		--template-file cloudFormationTemplates/ecs-cluster.yaml \
		--no-fail-on-empty-changeset \
		--capabilities CAPABILITY_IAM \
		--stack-name ${STACK_NAME} \
		--parameter-overrides \
			VpcId=${VPC_ID} \
			$$([ "${ENVIRONMENT}" == '' ] || echo "Environment=${ENVIRONMENT}" ) \
			KeyName=${KEY_NAME} \
			EcsClusterName=${ECS_CLUSTER_NAME} \
			UserName=${USER_NAME}

delete:
	@aws cloudformation delete-stack \
		--stack-name ${STACK_NAME}