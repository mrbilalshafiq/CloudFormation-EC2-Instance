 #!/usr/bin/bash
 
git clone https://github.com/mrbilalshafiq/CloudFormation-EC2-Instance && cd CloudFormation-EC2-Instance
mkdir -p ~/.ssh && chmod 700 $_
key_name="CloudFormationKeyPair"
aws ec2 create-key-pair --key-name ${key_name} --query 'KeyMaterial' --output text > ~/.ssh/${key_name}.pem
chmod 600 ~/.ssh/${key_name}.pem
aws cloudformation create-stack --stack-name test-stack --template-body file://test-stack.yaml
aws cloudformation wait stack-create-complete --stack-name test-stack
instance_id=$(aws cloudformation describe-stack-resources --stack-name test-stack | jq -r '.StackResources[] | select(.StackName == "test-stack" and .ResourceType == "AWS::EC2::Instance") | .PhysicalResourceId') 
dns_name=$(aws ec2 describe-instances | jq -r --arg instance_id ${instance_id} '.Reservations[] | .Instances[] | select(.InstanceId == $instance_id) | .PublicDnsName') 
ssh-keyscan -H ${dns_name} >> ~/.ssh/known_hosts
ssh -i ~/.ssh/CloudFormationKeyPair.pem ubuntu@${dns_name}
