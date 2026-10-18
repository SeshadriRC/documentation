# AWS CLI Commands for DevOps Engineers

A comprehensive reference for AWS cloud infrastructure operations, EKS cluster access, security, storage, container registries, and instance troubleshooting.

---

## 1. Authentication, Identity & Configuration

```bash
# Verify current AWS credentials, account ID, and IAM identity
aws sts get-caller-identity

# Configure a named profile interactively
aws configure --profile production
aws configure --profile sesha-write

# List configured profiles
aws configure list-profiles

# Set the active profile for current shell session
export AWS_PROFILE=sesha-write
export AWS_DEFAULT_REGION=ap-south-1

# Assume an IAM Role and capture temporary credentials
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/DevOpsDeploymentRole" \
  --role-session-name "ci-session-$(date +%s)"

# Export assumed role credentials to environment variables
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

---

## 2. Amazon EKS (Elastic Kubernetes Service)

```bash
# Update local ~/.kube/config to connect kubectl to an EKS cluster
aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster

# Update kubeconfig using a specific IAM role
aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster --role-arn arn:aws:iam::123456789012:role/EKSAdminRole

# List all EKS clusters in a region
aws eks list-clusters --region ap-south-1

# Inspect cluster endpoint, version, status, and VPC configuration
aws eks describe-cluster --name my-eks-cluster --query "cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}" --output table

# List managed nodegroups in an EKS cluster
aws eks list-nodegroups --cluster-name my-eks-cluster

# Describe a specific nodegroup (scaling config, instance types, status)
aws eks describe-nodegroup --cluster-name my-eks-cluster --nodegroup-name primary-workers
```

---

## 3. Amazon EC2 & Networking

```bash
# List running EC2 instances with Instance ID, Private IP, Public IP, and Name tag
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key=='Name']|[0].Value,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress,Type:InstanceType}" \
  --output table

# Start, stop, or reboot an EC2 instance
aws ec2 start-instances --instance-ids i-0a1b2c3d4e5f6g7h8
aws ec2 stop-instances --instance-ids i-0a1b2c3d4e5f6g7h8
aws ec2 reboot-instances --instance-ids i-0a1b2c3d4e5f6g7h8

# List VPCs and Subnets
aws ec2 describe-vpcs --query "Vpcs[*].{VpcId:VpcId,CidrBlock:CidrBlock,Name:Tags[?Key=='Name']|[0].Value}" --output table
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0a1b2c3d4e5f" --query "Subnets[*].{SubnetId:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}" --output table

# List Security Groups and rules
aws ec2 describe-security-groups --group-ids sg-0123456789abcdef0

# Authorize ingress rule (e.g. allow port 443 from specific CIDR)
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp \
  --port 443 \
  --cidr 10.0.0.0/16

# Revoke ingress rule
aws ec2 revoke-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

---

## 4. Amazon EBS Volumes & Disk Management

```bash
# List all attached and unattached EBS volumes
aws ec2 describe-volumes \
  --query "Volumes[*].{ID:VolumeId,SizeGB:Size,State:State,Type:VolumeType,AttachedTo:Attachments[0].InstanceId}" \
  --output table

# Increase EBS volume size on the fly (e.g. increase to 50 GB)
aws ec2 modify-volume --volume-id vol-0123456789abcdef0 --size 50

# Check modification progress
aws ec2 describe-volumes-modifications --volume-ids vol-0123456789abcdef0

# Create an on-demand snapshot of an EBS volume before maintenance
aws ec2 create-snapshot \
  --volume-id vol-0123456789abcdef0 \
  --description "Backup before application upgrade $(date +%F)"
```

---

## 5. Amazon S3 (Simple Storage Service)

```bash
# List S3 buckets
aws s3 ls

# List contents of a bucket with human-readable file sizes
aws s3 ls s3://my-app-backups/ --human-readable

# Copy a single file to/from S3
aws s3 cp release-v1.0.tar.gz s3://my-app-artifacts/builds/
aws s3 cp s3://my-app-artifacts/builds/release-v1.0.tar.gz ./

# Sync local directory to S3 bucket (deleting removed files)
aws s3 sync ./dist/ s3://my-frontend-bucket/ --delete

# Create and delete S3 bucket
aws s3 mb s3://my-new-unique-bucket-2026 --region ap-south-1
aws s3 rb s3://my-old-bucket --force    # Recursively deletes objects then deletes bucket

# Generate a temporary pre-signed URL for secure download (valid for 1 hour)
aws s3 presign s3://my-app-artifacts/logs.zip --expires-in 3600
```

---

## 6. Amazon ECR (Elastic Container Registry)

```bash
# Authenticate Docker daemon to Amazon ECR registry
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-south-1.amazonaws.com

# Create an ECR repository with image scan on push enabled
aws ecr create-repository \
  --repository-name my-service \
  --image-scanning-configuration scanOnPush=true \
  --region ap-south-1

# List repositories
aws ecr describe-repositories --output table

# List latest 10 image tags in a repository
aws ecr list-images --repository-name my-service --query "imageIds[*].imageTag" --output text
```

---

## 7. AWS SSM (Systems Manager) & Secrets Manager

```bash
# Connect securely to an EC2 instance via AWS SSM Session Manager (No SSH keys or open port 22 needed)
aws ssm start-session --target i-0a1b2c3d4e5f6g7h8

# Fetch a decrypted parameter from SSM Parameter Store
aws ssm get-parameter --name "/production/database/password" --with-decryption --query "Parameter.Value" --output text

# Put / Update a SecureString parameter in SSM Parameter Store
aws ssm put-parameter \
  --name "/production/api/stripe_key" \
  --value "sk_live_12345" \
  --type "SecureString" \
  --overwrite

# Retrieve secret value from AWS Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id "production/app/credentials" \
  --query "SecretString" \
  --output text | jq .
```

---

## 8. Amazon RDS (Relational Database Service)

```bash
# List all RDS database instances, engine, status, and endpoints
aws rds describe-db-instances \
  --query "DBInstances[*].{DB:DBInstanceIdentifier,Engine:Engine,Class:DBInstanceClass,Status:DBInstanceStatus,Endpoint:Endpoint.Address}" \
  --output table

# Create a manual DB snapshot before risky migrations
aws rds create-db-snapshot \
  --db-instance-identifier database-1 \
  --db-snapshot-identifier "database-1-pre-migration-$(date +%F)"

# Reboot an RDS instance (optionally with failover for Multi-AZ)
aws rds reboot-db-instance --db-instance-identifier database-1 --force-failover
```

---

## 9. Amazon CloudWatch Logs & Metrics

```bash
# Tail live log streams from a CloudWatch log group (similar to tail -f)
aws logs tail /aws/eks/my-eks-cluster/cluster --follow

# Tail logs since 15 minutes ago
aws logs tail /aws/containerinsights/my-eks-cluster/application --since 15m --filter-pattern "ERROR"

# List CloudWatch log groups matching prefix
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda" --output table
```
