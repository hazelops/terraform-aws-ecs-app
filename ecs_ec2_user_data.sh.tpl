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
