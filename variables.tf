variable "name" {
  description = "Name tag applied to the instance."
  type        = string
}

variable "ami" {
  description = "AMI ID to launch the instance from."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance into. Null uses the default subnet."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the EC2 key pair to associate with the instance."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instance."
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Whether to enable detailed CloudWatch monitoring."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script to run at instance launch."
  type        = string
  default     = null
}

variable "root_volume_type" {
  description = "Type of the root EBS volume."
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 8
}

variable "root_volume_encrypted" {
  description = "Whether the root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the instance."
  type        = map(string)
  default     = {}
}
