#!/bin/bash
# Monitoring Disk Usage on Amazon ECS EC2
cat <<'EOF' >> /etc/ecs/cw_ecsmetrics.sh
#!/bin/bash

### Get docker free data and push to CloudWatch metrics
### 
### requirements:
###  * must be run from inside an EC2 instance
###  * docker with devicemapper backing storage
###  * aws-cli configured with instance-profile/user with the put-metric-data permissions
###  * local user with rights to run docker cli commands

# install aws-cli, bc and jq if required
if [ ! -f /usr/bin/aws ]; then
  yum -qy -d 0 -e 0 install aws-cli
fi
if [ ! -f /usr/bin/bc ]; then
  yum -qy -d 0 -e 0 install bc
fi
if [ ! -f /usr/bin/jq ]; then
  yum -qy -d 0 -e 0 install jq
fi

# Collect region and instanceid from metadata
AWSREGION=`curl -ss http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`
AWSINSTANCEID=`curl -ss http://169.254.169.254/latest/meta-data/instance-id`

data=$(df -B1 /dev/xvda1 | awk 'NR==2{print $4}')
aws cloudwatch put-metric-data --value $data --namespace ECS/${env}-${ec2_service_group} --unit Bytes --metric-name FreeDataStorage --region $AWSREGION
EOF

chmod +x /etc/ecs/cw_ecsmetrics.sh
echo "*/5 * * * * root /etc/ecs/cw_ecsmetrics.sh" > /etc/cron.d/ecsmetrics

# ECS config
{
    echo "ECS_CLUSTER=${ecs_cluster_name}"
    echo "ECS_INSTANCE_ATTRIBUTES={\"service-group\":\"${ec2_service_group}\"}"
    echo "ECS_ENABLE_TASK_IAM_ROLE=true"
    echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m"
    echo "ECS_IMAGE_CLEANUP_INTERVAL=10m"
    echo "ECS_IMAGE_MINIMUM_CLEANUP_AGE=15m"
    echo "ECS_NUM_IMAGES_DELETE_PER_CYCLE=10"
} >> /etc/ecs/ecs.config
start ecs
echo "Done"

# ASG Auto Assign Elastic IP
TIMEOUT=20
PAUSE=5

apt-get update
apt install -y curl awscli

aws_get_instance_id() {
	instance_id=$( (curl http://169.254.169.254/latest/meta-data/instance-id) )
	if [ -n "$instance_id" ];	then return 0; else return 1; fi
}

aws_get_instance_region() {
	instance_region=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
	# region here needs the last character removed to work
	instance_region=${instance_region::-1}
	if [ -n "$instance_region" ];	then return 0; else return 1; fi
}

aws_get_instance_environment() {
	instance_environment=$(aws ec2 describe-tags --region $instance_region --filters "Name=resource-id,Values=$1" "Name=key,Values=env" --query "Tags[*].Value" --output text)
	if [ -n "$instance_environment" ]; then return 0; else return 1; fi
}

aws_get_unassigned_eips() {
	local describe_addreses_response=$(aws ec2 describe-addresses --region $instance_region --filters "Name=tag:env,Values=$instance_environment" --query "Addresses[?AssociationId==null].AllocationId" --output text)
	eips=(${describe_addreses_response///})
	if [ -n "$describe_addreses_response" ]; then return 0; else return 1; fi
}

aws_get_details() {
	if aws_get_instance_id;	then
		echo "Instance ID: ${instance_id}."
		if aws_get_instance_region;	then
			echo "Instance Region: ${instance_region}."
			if aws_get_instance_environment $instance_id;	then
				echo "Instance Environment (env): ${instance_environment}."
			else
				echo "Failed to get Instance Environment (env). ${instance_environment}."
				return 1
			fi
		else
			echo "Failed to get Instance Region. ${instance_region}."
			return 1
		fi
	else
		echo "Failed to get Instance ID. ${instance_id}."
		return 1
	fi
}

attempt_to_assign_eip() {
	local result;
	local exit_code;
  	result=$( (aws ec2 associate-address --region $instance_region --instance-id $instance_id --allocation-id $1 --no-allow-reassociation) 2>&1 )
	exit_code=$?
	if [ "$exit_code" -ne 0 ]; then
		echo "Failed to assign Elastic IP [$1] to Instance [$instance_id]. ERROR: $result"
	fi
  return $exit_code
}

try_to_assign() {
	local last_result;
	for eip_id in "${eips[@]}"; do
		echo "Attempting to assign Elastic IP to instance..."
		if attempt_to_assign_eip $eip_id;  then
			echo "Elastic IP successfully assigned to instance."
			return 0
		fi
	done
	return 1
}

main() {
	echo "Assigning Elastic IP..."
	local end_time=$((SECONDS+TIMEOUT))
	echo "Timeout: ${end_time}"

	if ! aws_get_details; then
		exit 1
	fi

	while [ $SECONDS -lt $end_time ]; do
		if aws_get_unassigned_eips && try_to_assign ${eips}; then
			echo "Successfully assigned EIP."
			exit 0
		fi
		echo "Failed to assign EIP. Pausing for $PAUSE seconds before retrying..."
		sleep $PAUSE
	done

	echo "Failed to assign Elastic IP after $TIMEOUT seconds. Exiting."
	exit 1
}

declare instance_id
declare instance_region
declare instance_environment
declare eips

if [ "${auto_assign_eip}" == "true" ]; then
    main "$@"
else
    echo "ASG Auto Assign Elastic IP is DISABLED."
fi
