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
