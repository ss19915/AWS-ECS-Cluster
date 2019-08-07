include .env

ENVIRONMENT := $(if $(ENVIRONMENT),$(ENVIRONMENT),dev)
ECS_STACK_NAME = ${PROJECT}-${STACK_NAME}-Cluster-${ENVIRONMENT}
TASK_STACK_NAME = ${PROJECT}-${STACK_NAME}-Task-${ENVIRONMENT}
ECS_CLUSTER_NAME = ${PROJECT}-${CLUSTER_NAME}-${ENVIRONMENT}
TARGET_GROUP_NAME = ${PROJECT}-Target-Group-${ENVIRONMENT}
LOAD_BALANCER_NAME = ${PROJECT}-LoadBalancer-${ENVIRONMENT}
SERVICE_NAME = ${PROJECT}-service-${ENVIRONMENT}
TARGET_GROUP_ARN_NAME = ${PROJECT}-targetGroupArn-${ENVIRONMENT}
AUTO_SCALING_LAUNCH_CONFIGURATION_NAME = ${PROJECT}-LaunchConfiguration-${ENVIRONMENT}
AUTO_SCALING_GROUP_NAME = ${PROJECT}-GroupName-${ENVIRONMENT}

deploy:
	@${MAKE} createEcs
	@${MAKE} createTask

deleteAll:
	@${MAKE} deleteTask
	@${MAKE} deleteEcs

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
			UserName=${USER_NAME} \
			TargetGroupName=${TARGET_GROUP_NAME} \
			LoadBalancerName=${LOAD_BALANCER_NAME} \
			VpcCird=${VPC_CIDR} \
			VpcSubnets=${VPC_SUBNETS} \
			TargetGroupArnName=${TARGET_GROUP_ARN_NAME} \
			LaunchConfigurationName=${AUTO_SCALING_LAUNCH_CONFIGURATION_NAME} \
			AutoScalingGroupName=${AUTO_SCALING_GROUP_NAME}

	@${MAKE} ecsOutput

deleteEcs:
	@echo Deleting ECS Cluster . . . . . 
	@aws cloudformation delete-stack \
		--stack-name ${ECS_STACK_NAME}
	@aws cloudformation wait stack-delete-complete \
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
			$$([[ '${TASK_DESIRED_COUNT}' == '' ]] || echo 'DesiredCount=${TASK_DESIRED_COUNT}') \
			ServiceName=${SERVICE_NAME} \
			LoadBalancerName=${LOAD_BALANCER_NAME} \
			TargetGroupArnName=${TARGET_GROUP_ARN_NAME}

deleteTask:
	@echo Deleting ECS TaskDefinition . . . . . 
	@aws cloudformation delete-stack \
		--stack-name ${TASK_STACK_NAME}
	@aws cloudformation wait stack-delete-complete \
		--stack-name ${TASK_STACK_NAME}	

ecsOutput:
	@aws cloudformation describe-stacks --stack-name ${ECS_STACK_NAME} --query "Stacks[0].Outputs" 