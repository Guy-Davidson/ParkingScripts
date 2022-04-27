$DateTime = (Get-Date).ToUniversalTime() 
$UnixTimeStamp = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))

$KEY_NAME = "Cloud-Computing-" + $UnixTimeStamp
$KEY_PEM = $KEY_NAME + ".pem"

aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_PEM

$SEC_GRP = "scriptSG-" + $UnixTimeStamp
aws ec2 create-security-group --group-name $SEC_GRP --description "script gen sg"

$MY_IP = curl https://checkip.amazonaws.com
aws ec2 authorize-security-group-ingress `
	--group-name $SEC_GRP `
	--protocol tcp `
	--port 22 `
	--cidr $MY_IP/32 
	
aws ec2 authorize-security-group-ingress `
	--group-name $SEC_GRP `
	--protocol tcp `
	--port 5000 `
	--cidr 0.0.0.0/0
	
$UBUNTU_20_04_AMI = "ami-08ca3fed11864d6bb"
$RUN_INSTANCES = (aws ec2 run-instances `
					--image-id $UBUNTU_20_04_AMI `
					--instance-type t2.micro `
					--key-name $KEY_NAME `
					--security-groups $SEC_GRP)				

$RUN_INSTANCES_Convert = $RUN_INSTANCES | ConvertFrom-Json
$INSTANCE_ID = $RUN_INSTANCES_Convert.Instances[0].InstanceId

aws ec2 wait instance-running --instance-ids $INSTANCE_ID

$Describe_Instances = aws ec2 describe-instances --instance-ids $INSTANCE_ID
$Describe_Instances_Convert = $Describe_Instances | ConvertFrom-Json
$PUBLIC_IP = $Describe_Instances_Convert.Reservations[0].Instances[0].PublicIpAddress

ssh -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP "mkdir .aws"

scp -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" credentials ubuntu@${PUBLIC_IP}:~/.aws/

scp -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" config ubuntu@${PUBLIC_IP}:~/.aws/

scp -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" mongodbKey.txt ubuntu@${PUBLIC_IP}:/home/ubuntu/

scp -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" onCloudScript.bash ubuntu@${PUBLIC_IP}:/home/ubuntu/

ssh -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP "sudo bash ~/onCloudScript.bash"

ssh -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP "aws configure list"

ssh -i $KEY_PEM -o "StrictHostKeyChecking=no" -o "ConnectionAttempts=10" ubuntu@$PUBLIC_IP "cd app && node index.js"