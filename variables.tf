variable "aws_region" {
  description = "AWS region in which to launch servers"
  default    = "us-east-1"
}

variable "aws_amis" {
  description = "AMI identifier"
  default    = {
    "us-east-1" = "ami-73709f18"
    "us-west-1" = "ami-555cb711"
    "us-west-2" = "ami-0f675e3f"
  }
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

# Arguments provided to the script
variable "app" {
  description = "Name of the application to deploy"
  default     = "hello_world"
}

variable "private_ssh_key_path" {
  description = "Path to private key .pem file"
  default     = "/Users/katie/.aws/ssh/MyNVKeyPair.pem"
}

variable "env" {
  description = "Environment in which to deploy"
  default     = "dev"
}

variable "number_servers" {
  description = "Number of EC2 servers launched"
  default     = 2
}

variable "server_size" {
  description = "Size of server launched"
  default     = "t1.micro"
}
