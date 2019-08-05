include .env

ENVIRONMENT := $(if $(ENVIRONMENT),$(ENVIRONMENT),dev)
ECS_STACK_NAME = ${PROJECT}-${STACK_NAME}-Cluster-${ENVIRONMENT}
TASK_STACK_NAME = ${PROJECT}-${STACK_NAME}-Task-${ENVIRONMENT}
ECS_CLUSTER_NAME = ${PROJECT}-${CLUSTER_NAME}-${ENVIRONMENT}

deploy:
	@${MAKE} createEcs
	@${MAKE} createTask

deleteAll:
	@${MAKE} deleteEcs
	@${MAKE} deleteTask

createEcs:
	@echo Creating/Updating ECS Cluster . . . . . . . 
	@aws cloudformation deploy \
		--region ${REGION} \
		--template-file cloudFormationTemplates/ecsCluster.yaml \
		--no-fail-on-empty-changeset \
		--capabilities CAPABILITY_IAM \
		--stack-name ${ECS_STACK_NAME} \
		--parameter-overrides \
			VpcId=${VPC_ID} \
			KeyName=${KEY_NAME} \
			EcsClusterName=${ECS_CLUSTER_NAME} \
			UserName=${USER_NAME}

deleteEcs:
	@echo Deleting ECS Cluster . . . . . 
	@aws cloudformation delete-stack \
		--stack-name ${ECS_STACK_NAME}

createTask:
	@echo Creating/Updating ECS TaskDefinition . . . . . . . 
	@aws cloudformation deploy \
		--region ${REGION} \
		--template-file cloudFormationTemplates/ecsTask.yaml \
		--no-fail-on-empty-changeset \
		--capabilities CAPABILITY_IAM \
		--stack-name ${TASK_STACK_NAME} \
		--parameter-overrides \
			EcsClusterName=${ECS_CLUSTER_NAME} \
			$$([[ '${TASK_DESIRED_COUNT}' == '' ]] || echo 'DesiredCount=${TASK_DESIRED_COUNT}')

deleteTask:
	@echo Deleting ECS TaskDefinition . . . . . 
	@aws cloudformation delete-stack \
		--stack-name ${TASK_STACK_NAME}
