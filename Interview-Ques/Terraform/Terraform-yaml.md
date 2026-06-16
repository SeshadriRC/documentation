**1. Basic terraform EC2 Yaml**

```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  ami             = "ami-0f58b397bc5c1f2e8"
  instance_type   = "t2.micro"
  key_name        = "my-key"
  security_groups = ["default"]

  tags = {
    Name = "dev-server"
  }
}
```

---
**2. Create multiple EC2 Instance**

For interview/basic Terraform, use **`count`** to create multiple EC2 instances.

```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  count = 3

  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  tags = {
    Name = "server-${count.index + 1}"
  }
}
```

### Explanation:

* `count = 3` → Creates **3 EC2 instances**
* `count.index` → Gives index `0,1,2`
* Names become:

  ```text
  server-1
  server-2
  server-3
  ```

Commands:

```bash
terraform init
terraform plan
terraform apply
```

Another approach using **for_each** (more flexible):

```hcl
provider "aws" {
  region = "ap-south-1"
}

variable "servers" {
  default = ["app", "db", "web"]
}

resource "aws_instance" "ec2" {
  for_each = toset(var.servers)

  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  tags = {
    Name = each.value
  }
}
```

This creates:

```text
app
db
web
```

Interview answer:

> **Use `count` for identical multiple resources, use `for_each` when each resource has different values/configurations.**

---
