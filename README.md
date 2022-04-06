# CloudFormation-EC2-Instance
> Creating an EC2 instance using CloudFormation

## Prerequisites
* You will need the AWSCLI configured with the reqion set to eu-west-2
* jq installed (sudo apt install -y jq)

## Step-by-Step Guide

1. Clone the repo and cd into it

        git clone https://github.com/mrbilalshafiq/CloudFormation-EC2-Instance && cd CloudFormation-EC2-Instance
        
 * From here you could enter the below or continue entering the rest of the commands manually
        
        bash script.sh

2. Make sure SSH folder exists with the correct permissions

        mkdir -p ~/.ssh && chmod 700 $_
        
3. Set the key pair name

        key_name="CloudFormationKeyPair"

4. Create a key pair

        aws ec2 create-key-pair --key-name ${key_name} --query 'KeyMaterial' --output text > ~/.ssh/${key_name}.pem
        
5. Make sure the private key has the correct permissions

        chmod 600 ~/.ssh/${key_name}.pem
        
6. Create the stack using the template provided        

        aws cloudformation create-stack --stack-name test-stack --template-body file://test-stack.yaml
        
7. Wait until it's ready, you can either use this command to programatically wait or just look on the AWS Management Console to check

        aws cloudformation wait stack-create-complete --stack-name test-stack
        
8. Get the ID of the newly created instance

        instance_id=$(aws cloudformation describe-stack-resources --stack-name test-stack | jq -r '.StackResources[] | select(.StackName == "test-stack" and .ResourceType == "AWS::EC2::Instance") | .PhysicalResourceId') 
        
9. Get the DNS name of the instance using the instance ID

        dns_name=$(aws ec2 describe-instances | jq -r --arg instance_id ${instance_id} '.Reservations[] | .Instances[] | select(.InstanceId == $instance_id) | .PublicDnsName')
        
10. Add instances to known hosts to avoid the yes/no prompt when connecting for the first time

        ssh-keyscan -H ${dns_name} >> ~/.ssh/known_hosts
        
11. Finally, connect with SSH using the private key

        ssh -i ~/.ssh/CloudFormationKeyPair.pem ubuntu@${dns_name}
        
## Clean up

1. Delete the stack 

        aws cloudformation delete-stack --stack-name test-stack
        
2. Delete the key pair

        aws ec2 delete-key-pair --key-name ${key_name}
        
3. Remove the private key

        rm ~/.ssh/${key_name}.pem
