import boto3
def lambda_handler(event, context):
    # Create an EC2 client
    ec2_client = boto3.client('ec2')
    # Describe instances in eu-west-1
    response = ec2_client.describe_instances()
    # Iterate over instances and print their information
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            instance_state = instance['State']['Name']
            print(f"Instance ID: {instance_id}")
            print(f"Instance State: {instance_state}")
            # Stop the instance
            ec2_client.stop_instances(InstanceIds=[instance_id])
            print(f"Stopped instance with ID: {instance_id}")
            print('-----------------------')