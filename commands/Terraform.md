# Terraform Commands for DevOps Engineers

A comprehensive reference for Infrastructure as Code (IaC) lifecycle management, state manipulation, debugging, and multi-environment orchestration.

---

## 1. Initialization & Provider Management

```bash
# Initialize working directory, download required providers and child modules
terraform init

# Upgrade providers and modules to the latest allowed versions
terraform init -upgrade

# Reconfigure backend without copying existing state (useful after changing backend config)
terraform init -reconfigure

# Migrate state from one backend to another (e.g., local to S3/GCS)
terraform init -migrate-state

# Ignore backend initialization (useful for syntax checking in CI without cloud credentials)
terraform init -backend=false
```

---

## 2. Formatting & Validation

```bash
# Format all Terraform configuration files in current directory and subdirectories
terraform fmt -recursive

# Check if files are properly formatted without making changes (exit code 0 if formatted, non-zero for CI)
terraform fmt -check -recursive -diff

# Validate configuration files for syntax and internal consistency (does not access remote APIs)
terraform validate

# Validate configuration and output machine-readable JSON (ideal for CI/CD gates)
terraform validate -json
```

---

## 3. Planning & Speculative Execution

```bash
# Generate and show an execution plan
terraform plan

# Plan with a specific variable file
terraform plan -var-file="environments/production.tfvars"

# Pass individual variables on the command line
terraform plan -var="environment=prod" -var="instance_count=5"

# Save the generated plan to an encrypted binary file (standard CI/CD best practice)
terraform plan -out=tfplan.binary

# Plan specifically for destroying resources
terraform plan -destroy -out=destroy.binary

# Inspect a saved binary plan in human-readable or JSON format
terraform show tfplan.binary
terraform show -json tfplan.binary | jq .
```

---

## 4. Applying Changes

```bash
# Apply changes interactively (prompts for confirmation)
terraform apply

# Apply a pre-generated, validated plan file (recommended for production CI/CD)
terraform apply tfplan.binary

# Apply without interactive prompt (use strictly in automated CI/CD pipelines)
terraform apply -auto-approve

# Apply with specific variable file
terraform apply -var-file="environments/production.tfvars" -auto-approve

# Target specific resource or module (use sparingly for hotfixes/emergencies)
terraform apply -target=module.vpc.aws_route_table.public
terraform apply -target=aws_security_group.allow_tls
```

---

## 5. Destroying Infrastructure

```bash
# Destroy all managed infrastructure interactively
terraform destroy

# Destroy infrastructure using a specific variable file without confirmation prompt
terraform destroy -var-file="environments/staging.tfvars" -auto-approve

# Destroy only a targeted resource
terraform destroy -target=aws_instance.bastion -auto-approve
```

---

## 6. State Management & Inspection (DevOps Critical)

```bash
# List all resources currently tracked in the state file
terraform state list

# Filter state list with grep
terraform state list | grep aws_s3_bucket

# Show attributes of a specific resource in the state file
terraform state show aws_instance.web_server
terraform state show module.vpc.aws_subnet.public[0]

# Move or rename a resource in the state file without recreating it
terraform state mv aws_instance.old_name aws_instance.new_name
terraform state mv aws_security_group.sg module.security.aws_security_group.sg

# Remove a resource from state file (Terraform stops tracking it, but DOES NOT delete the cloud resource)
terraform state rm aws_s3_bucket.legacy_data
terraform state rm module.deprecated_module

# Download and pull the current remote state to a local file
terraform state pull > terraform.tfstate.backup

# Force-push a corrected state file back to remote backend (Use with extreme caution)
terraform state push terraform.tfstate.backup

# Update local state against real-world cloud resources without making changes
terraform refresh
```

---

## 7. Workspaces (Multi-Environment Isolation)

```bash
# List all existing workspaces
terraform workspace list

# View current active workspace
terraform workspace show

# Create and switch to a new workspace
terraform workspace new staging
terraform workspace new production

# Switch between existing workspaces
terraform workspace select production
terraform workspace select default

# Delete an empty workspace
terraform workspace delete staging
```

---

## 8. Importing Existing Infrastructure

```bash
# Import an existing cloud resource into Terraform state (Terraform 1.4 and older)
terraform import aws_instance.web i-0123456789abcdef0
terraform import aws_s3_bucket.my_bucket company-production-assets
terraform import module.vpc.aws_vpc.main vpc-0a1b2c3d4e5f

# Terraform 1.5+ Declarative Import block in .tf file:
# import {
#   to = aws_s3_bucket.my_bucket
#   id = "company-production-assets"
# }
# Then generate configuration automatically:
terraform plan -generate-config-out=generated_resources.tf
```

---

## 9. Forcing Resource Recreation (Replace / Taint)

```bash
# Mark a resource to be destroyed and recreated on next apply (Terraform 1.0+)
terraform apply -replace="aws_instance.web"

# Replace a specific instance inside a module
terraform apply -replace="module.database.aws_db_instance.primary"

# Legacy taint command (marks resource degraded in state)
terraform taint aws_instance.web
terraform untaint aws_instance.web
```

---

## 10. Outputs & Interactive Console

```bash
# View all root module output values
terraform output

# View a specific output value
terraform output vpc_id
terraform output -raw rds_endpoint    # Raw string without quotation marks (great for bash scripts)

# Output all values as JSON
terraform output -json

# Launch interactive evaluation console (evaluates HCL expressions against current state)
terraform console
# Inside console:
# > local.common_tags
# > aws_subnet.public.*.id
# > length(var.availability_zones)
# > exit
```

---

## 11. Debugging & Graphing

```bash
# Enable verbose debug logging to stderr or a file
export TF_LOG=DEBUG
export TF_LOG_PATH=/tmp/terraform-debug.log
terraform plan

# Turn off debug logging
unset TF_LOG
unset TF_LOG_PATH

# Generate visual dependency graph in DOT format
terraform graph | dot -Tsvg > terraform-dependency-graph.svg
```
