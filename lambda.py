import boto3
def lambda_handler(event, context):
    autoscaling_group_name = 'my_autoscaling_group'

    autoscaling_client = boto3.client('autoscaling')
    response = autoscaling_client.describe_auto_scaling_instances()

    instances = [instance for instance in response['AutoScalingInstances'] if
                 instance['AutoScalingGroupName'] == autoscaling_group_name]

    autoscaling_client.suspend_processes(AutoScalingGroupName=autoscaling_group_name)

    ec2_client = boto3.client('ec2')
    for instance in instances:
        instance_id = instance['InstanceId']
        ec2_client.stop_instances(InstanceIds=[instance_id])
