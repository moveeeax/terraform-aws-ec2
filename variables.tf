variable "name" {
  description = "Name tag applied to the instance."
  type        = string
}

variable "ami" {
  description = "AMI ID to launch the instance from."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{8}([0-9a-f]{9})?$", var.ami))
    error_message = "The ami value must be an AMI ID, for example \"ami-0abcdef1234567890\"."
  }
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
  description = <<-EOT
    User data script to run at instance launch. Marked sensitive so that it is
    redacted from plan output and CI logs, because user data is a common place
    for bootstrap credentials to end up. Note that EC2 stores user data
    unencrypted and any process on the instance can read it from IMDS, so
    prefer SSM Parameter Store or Secrets Manager for real secrets.
  EOT
  type        = string
  default     = null
  sensitive   = true
}

variable "root_volume_type" {
  description = "Type of the root EBS volume."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.root_volume_type)
    error_message = "The root_volume_type value must be one of gp2, gp3, io1, io2 or standard."
  }
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size >= 1 && var.root_volume_size <= 16384 && floor(var.root_volume_size) == var.root_volume_size
    error_message = "The root_volume_size value must be a whole number of GiB between 1 and 16384."
  }
}

variable "root_volume_encrypted" {
  description = "Whether the root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "root_volume_iops" {
  description = <<-EOT
    Provisioned IOPS for the root EBS volume. AWS requires this to be set
    explicitly when root_volume_type is "io1" or "io2" (there is no default);
    it is an optional performance tuning knob for "gp3" and ignored for other
    volume types.
  EOT
  type        = number
  default     = null
}

variable "root_volume_throughput" {
  description = "Throughput (MiB/s) for the root EBS volume. Only applies to \"gp3\" volumes."
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags applied to the instance."
  type        = map(string)
  default     = {}
}
