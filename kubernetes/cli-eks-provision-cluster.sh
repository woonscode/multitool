#!/bin/sh

## OUTDATED - REFER TO TERRAFORM MODULES INSTEAD ##
set -e

region="ap-southeast-1"
account_id="PLACEHOLDER"
registry_url="$account_id.dkr.ecr.$region.amazonaws.com"

# # Create VPC with public and private subnet networking - (NOTE: subnets 1 and 2 should be in different AZs)
# vpc_id=$(aws ec2 create-vpc --cidr-block "10.0.0.0/16" --tag-specification ResourceType=vpc,Tags=["{Key=Name,Value=eks-test}"] --query "Vpc.VpcId" --output text)
# private_subnet_1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone "ap-southeast-1a" --cidr-block "10.0.0.0/24" --tag-specification ResourceType=subnet,Tags=["{Key=Name,Value=eks-test-private-1},{Key=kubernetes.io/cluster/woonhao-test-dev,Value=owned},{Key=kubernetes.io/role/internal-elb,Value=1}"] --query "Subnet.SubnetId" --output text)
# private_subnet_2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone "ap-southeast-1b" --cidr-block "10.0.1.0/24" --tag-specification ResourceType=subnet,Tags=["{Key=Name,Value=eks-test-private-2},{Key=kubernetes.io/cluster/woonhao-test-dev,Value=owned},{Key=kubernetes.io/role/internal-elb,Value=1}"] --query "Subnet.SubnetId" --output text)
# public_subnet_1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone "ap-southeast-1a" --cidr-block "10.0.2.0/24" --tag-specification ResourceType=subnet,Tags=["{Key=Name,Value=eks-test-public-1},{Key=kubernetes.io/cluster/woonhao-test-dev,Value=owned},{Key=kubernetes.io/role/elb,Value=1}"] --query "Subnet.SubnetId" --output text)
# public_subnet_2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --availability-zone "ap-southeast-1b" --cidr-block "10.0.3.0/24" --tag-specification ResourceType=subnet,Tags=["{Key=Name,Value=eks-test-public-2},{Key=kubernetes.io/cluster/woonhao-test-dev,Value=owned},{Key=kubernetes.io/role/elb,Value=1}"] --query "Subnet.SubnetId" --output text)
# igw_id=$(aws ec2 create-internet-gateway --tag-specification ResourceType=internet-gateway,Tags=["{Key=Name,Value=eks-test"}] --query "InternetGateway.InternetGatewayId" --output text)
# aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id

# # Associate route table which has route pointing to internet gateway with public subnet
# public_rt_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specification ResourceType=route-table,Tags=["{Key=Name,Value=eks-test-public-rt}"] --query "RouteTable.RouteTableId" --output text)
# aws ec2 create-route --route-table-id $public_rt_id --destination-cidr-block "0.0.0.0/0" --gateway-id $igw_id
# aws ec2 associate-route-table --subnet-id $public_subnet_1_id --route-table-id $public_rt_id
# aws ec2 associate-route-table --subnet-id $public_subnet_2_id --route-table-id $public_rt_id

# # For each AZ - Allocate Elastic IP + Create NAT gateway for private instances to communicate externally to clients for API usage etc.
# ngw_eip_1_id=$(aws ec2 allocate-address --tag-specification ResourceType=elastic-ip,Tags=["{Key=Name,Value=eks-test-1}"] --query "AllocationId" --output text)
# ngw_1_id=$(aws ec2 create-nat-gateway --allocation-id $ngw_eip_1_id --subnet-id $public_subnet_1_id --tag-specification ResourceType=natgateway,Tags=["{Key=Name,Value=eks-test-1}"] --query "NatGateway.NatGatewayId" --output text)
# ngw_eip_2_id=$(aws ec2 allocate-address --tag-specification ResourceType=elastic-ip,Tags=["{Key=Name,Value=eks-test-2}"] --query "AllocationId" --output text)
# ngw_2_id=$(aws ec2 create-nat-gateway --allocation-id $ngw_eip_2_id --subnet-id $public_subnet_2_id --tag-specification ResourceType=natgateway,Tags=["{Key=Name,Value=eks-test-2}"] --query "NatGateway.NatGatewayId" --output text)

# # Associate route table which has route pointing to NAT gateway with public subnet
# private_rt_1_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specification ResourceType=route-table,Tags=["{Key=Name,Value=eks-test-private-rt-1}"] --query "RouteTable.RouteTableId" --output text)
# aws ec2 create-route --route-table-id $private_rt_1_id --destination-cidr-block "0.0.0.0/0" --nat-gateway-id $ngw_1_id
# aws ec2 associate-route-table --subnet-id $private_subnet_1_id --route-table-id $private_rt_1_id
# private_rt_2_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specification ResourceType=route-table,Tags=["{Key=Name,Value=eks-test-private-rt-2}"] --query "RouteTable.RouteTableId" --output text)
# aws ec2 create-route --route-table-id $private_rt_2_id --destination-cidr-block "0.0.0.0/0" --nat-gateway-id $ngw_2_id
# aws ec2 associate-route-table --subnet-id $private_subnet_2_id --route-table-id $private_rt_2_id

# # Specific to EKS Networking
# aws ec2 modify-vpc-attribute --enable-dns-support --vpc-id $vpc_id
# aws ec2 modify-vpc-attribute --enable-dns-hostnames --vpc-id $vpc_id

# # Any instance launched into this subnet receives public IP address
# aws ec2 modify-subnet-attribute --subnet-id $public_subnet_1_id --map-public-ip-on-launch
# aws ec2 modify-subnet-attribute --subnet-id $public_subnet_2_id --map-public-ip-on-launch

# # Create IAM Role for EKS
# aws iam create-role \
#   --role-name eks-test-role \
#   --assume-role-policy-document file://"terraform/policies/eks-test-cluster-iam-trust-policy.json" # allows EKS to assume this role

# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
#   --role-name eks-test-role

# # Create EKS Cluster
# aws eks create-cluster --name "woonhao-test-dev" --role-arn "arn:aws:iam::PLACEHOLDER:role/eks-test-role" --resources-vpc-config "$private_subnet_1_id,$private_subnet_2_id"

# # Check EKS cluster status
# aws eks describe-cluster \
#     --region ap-southeast-1 \
#     --name woonhao-test-dev \
#     --query "cluster.status"

# # Update kubectl kubeconfig - sometimes incompatible if the current kubeconfig file is populated or in the wrong format
# aws eks update-kubeconfig --name "woonhao-test-dev"

# # Create managed-node IAM role
# aws iam create-role \
#   --role-name "woonhao-test-dev-managed-node-role" \
#   --assume-role-policy-document file://"terraform/policies/eks-managed-node-role-trust-policy.json"    

# # Attach policy
# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
#   --role-name "woonhao-test-dev-managed-node-role"
# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
#   --role-name "woonhao-test-dev-managed-node-role"
# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
#   --role-name "woonhao-test-dev-managed-node-role"

# # Create AWS managed node groups
# asg_1_name=$(aws eks create-nodegroup --cluster-name "woonhao-test-dev" --nodegroup-name "eks-test-managed-nodegroup" --scaling-config minSize=2,maxSize=4,desiredSize=2 --subnets $private_subnet_1_id $private_subnet_2_id --instance-types "t3.small" --ami-type "AL2_x86_64" --remote-access ec2SshKey="python-webapp" --node-role "arn:aws:iam::PLACEHOLDER:role/woonhao-test-dev-managed-node-role" --query "nodegroup.resources.autoScalingGroups.name" --output text)
# asg_2_name=$(aws eks create-nodegroup --cluster-name "woonhao-test-dev" --nodegroup-name "eks-test-managed-nodegroup-2" --scaling-config minSize=2,maxSize=4,desiredSize=2 --subnets $private_subnet_1_id $private_subnet_2_id --instance-types "t3.small" --ami-type "AL2_x86_64" --remote-access ec2SshKey="python-webapp" --node-role "arn:aws:iam::PLACEHOLDER:role/woonhao-test-dev-managed-node-role" --query "nodegroup.resources.autoScalingGroups.name" --output text)

# # Adjust autoscaling policies to allow all processes
# aws autoscaling resume-processes --auto-scaling-group-name $asg_1_name
# aws autoscaling resume-processes --auto-scaling-group-name $asg_2_name

# # Add-ons
# aws eks create-addon \
#     --cluster-name "woonhao-test-dev" \
#     --addon-name coredns \
#     --resolve-conflicts OVERWRITE

# aws eks create-addon \
#     --cluster-name "woonhao-test-dev" \
#     --addon-name kube-proxy \
#     --resolve-conflicts OVERWRITE

# # Only if outdated
# aws eks update-addon \
#     --cluster-name "woonhao-test-dev" \
#     --addon-name kube-proxy \
#     --addon-version v1.22.11-eksbuild.2 \
#     --resolve-conflicts OVERWRITE

# # Create OIDC using console (troublesome through AWS CLI but easier through Terraform)

# aws eks create-addon \
#     --cluster-name "woonhao-test-dev" \
#     --addon-name vpc-cni \
#     --addon-version v1.11.2-eksbuild.1 \
#     --resolve-conflicts OVERWRITE

# Create namespace
kubectl create namespace "py-app"

# Create secret for container images to use to authenticate to private registry - not crucial as ecr-token-refresher CronJob will create this secret too
kubectl create secret docker-registry "ecr-credentials" \
  --docker-server="$registry_url" \
  --docker-username="AWS" \
  --docker-password=$(aws ecr get-login-password) \
  --namespace="py-app"

# # Create IAM policy for ALB
# aws iam create-policy \
#     --policy-name "woonhao-test-dev-alb-policy" \
#     --policy-document file://alb-iam-policy.json

# # Create role + attach policy to role
# aws iam create-role \
#   --role-name "woonhao-test-dev-alb-role" \
#   --assume-role-policy-document file://"alb-trust-policy.json"

# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::PLACEHOLDER:policy/woonhao-test-dev-alb-policy \
#   --role-name "woonhao-test-dev-alb-role"

# Install ALB Controller from Helm chart
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="woonhao-test-dev" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.repository=602401143452.dkr.ecr.ap-southeast-1.amazonaws.com/amazon/aws-load-balancer-controller

# Turn on nodes at 9am - Custodian-Scheduler-StartTime: on=(M-F,9);tz=sgt

# Need to manually change "[k8s] Shared Backend SecurityGroup for LoadBalancer" SG to allow incoming traffic from my IP as GovTech policy removes the 0.0.0.0/0 SG rule

# Deploy Metrics Server pre-req for Kubernetes Dashboard
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Deploy Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml

# Get auth token for eks-admin SA to use for admin permissions in Kubernetes Dashboard and copy paste into Web UI
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

# Start Kubernetes Dashboard on localhost
kubectl proxy

# Access URL: "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=_all" for Kubernetes Dashboard