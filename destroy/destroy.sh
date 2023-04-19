#!/bin/bash

# EC2 Instances
echo "Terminating EC2 Instances"

resources=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=tom-oscar*" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text)

for resource in $resources; do
	echo "Terminating $resource (will hang while it stops)"
		aws ec2 terminate-instances --instance-ids $resource > /dev/null
		aws ec2 wait instance-terminated --instance-ids $resource
done

# EC2 Network Interfaces
echo "Deleting Network Interfaces"

resources=$(aws ec2 describe-network-interfaces --filters "Name=tag:Name,Values=tom-oscar*" --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text)

for resource in $resources; do
		echo "Deleting $resource"
		aws ec2 delete-network-interface --network-interface-id $resource
done

# EC2 Internet Gateway Attachments
echo "Detaching Internet Gateway Attachments"

resources=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=tom-oscar*" --query 'InternetGateways[*].InternetGatewayId' --output text)

for resource in $resources; do
		echo "Detaching $resource"
		vpc=$(aws ec2 describe-internet-gateways --internet-gateway-ids $resource --query 'InternetGateways[*].Attachments[*].VpcId' --output text)
		aws ec2 detach-internet-gateway --internet-gateway-id $resource --vpc-id $vpc
done

# EC2 Internet Gateways
echo "Deleting Internet Gateways"

resources=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=tom-oscar*" --query 'InternetGateways[*].InternetGatewayId' --output text)

for resource in $resources; do
		echo "Deleting $resource"
		aws ec2 delete-internet-gateway --internet-gateway-id $resource
done


# EC2 Security Groups
echo "Deleting Security Groups"

resources=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=tom-oscar*" --query 'SecurityGroups[*].GroupId' --output text)

for resource in $resources; do
		# Check if default security group
		name=$(aws ec2 describe-security-groups --group-ids $resource --query 'SecurityGroups[*].GroupName' --output text)
		if [ "$name" == "default" ]; then
			echo "Skipping default security group"
			continue
		fi
		echo "Deleting $resource"
		aws ec2 delete-security-group --group-id $resource
done


# EC2 Subnets
echo "Deleting Subnets"

resources=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=tom-oscar*" --query 'Subnets[*].SubnetId' --output text)

for resource in $resources; do
		echo "Deleting $resource"
		aws ec2 delete-subnet --subnet-id $resource
done

# EC2 Route Tables
echo "Deleting Route Tables"

resources=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=tom-oscar*" --query 'RouteTables[*].RouteTableId' --output text)

for resource in $resources; do
		echo "Deleting $resource"
		aws ec2 delete-route-table --route-table-id $resource
done

# EC2 VPC
echo "Deleting VPC"

resources=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=tom-oscar*" --query 'Vpcs[*].VpcId' --output text)

for resource in $resources; do
		echo "Deleting $resource"
		aws ec2 delete-vpc --vpc-id $resource
done
