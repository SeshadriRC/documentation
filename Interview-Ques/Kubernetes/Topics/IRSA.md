**IRSA (IAM Roles for Service Accounts) in AWS EKS**

**Interview Answer (2 lines):**
 IRSA (IAM Roles for Service Accounts) allows Kubernetes pods in Amazon EKS to securely access AWS services by associating an IAM role with a Kubernetes Service Account. It eliminates the need to store AWS access keys inside pods.

**How it Works**
- Create an IAM Role with required AWS permissions.
- Configure EKS OIDC (OpenID Connect) provider.
- Associate the IAM Role with a Kubernetes Service Account.
- Pods using that Service Account receive temporary AWS credentials automatically.

**Example**

A pod needs to read files from an S3 bucket:

- Create an IAM role with s3:GetObject permission.
- Associate the role with a Service Account.
- Deploy pod using that Service Account.
- The application can access S3 without storing AWS keys.

**Benefits**
- Improved security (no hardcoded credentials).
- Least-privilege access for each application.
- Automatic credential rotation by AWS.
- Better auditability through IAM.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-reader
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/S3ReadRole
```
Real-Time Use Case

In a DevOps project, applications running in EKS often need access to S3, DynamoDB, Secrets Manager, or SQS. IRSA is the recommended AWS method to provide those permissions securely without using AWS Access Keys inside containers.
