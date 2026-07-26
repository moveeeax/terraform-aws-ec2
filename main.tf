resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  user_data                   = var.user_data

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_volume_encrypted
    iops        = var.root_volume_iops
    throughput  = var.root_volume_throughput
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    precondition {
      condition     = !contains(["io1", "io2"], var.root_volume_type) || var.root_volume_iops != null
      error_message = "root_volume_iops must be set when root_volume_type is \"io1\" or \"io2\"; AWS has no default IOPS for these volume types."
    }

    precondition {
      condition     = var.root_volume_throughput == null || var.root_volume_type == "gp3"
      error_message = "root_volume_throughput may only be set when root_volume_type is \"gp3\"."
    }
  }
}
