# Test-only requirement: `mock_provider` needs Terraform >= 1.7 / OpenTofu >= 1.7.
# The module itself still supports >= 1.5, so versions.tf is deliberately not bumped.

mock_provider "aws" {}

variables {
  name = "unit-test"
  ami  = "ami-0abcdef1234567890"
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = aws_instance.this.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must be required; optional tokens expose instance role credentials to SSRF."
  }

  assert {
    condition     = aws_instance.this.metadata_options[0].http_endpoint == "enabled"
    error_message = "The instance metadata endpoint should stay enabled."
  }

  assert {
    condition     = aws_instance.this.root_block_device[0].encrypted == true
    error_message = "The root EBS volume must be encrypted by default."
  }

  assert {
    condition     = aws_instance.this.root_block_device[0].volume_type == "gp3"
    error_message = "The root EBS volume should default to gp3."
  }

  assert {
    condition     = aws_instance.this.associate_public_ip_address == false
    error_message = "The module must not put instances on the public internet by default."
  }

  assert {
    condition     = aws_instance.this.monitoring == false
    error_message = "Detailed monitoring is a cost opt-in and must default to false."
  }
}

run "name_tag_is_merged_with_user_tags" {
  command = plan

  variables {
    tags = {
      Environment = "test"
      Name        = "should-be-overridden"
    }
  }

  assert {
    condition     = aws_instance.this.tags["Name"] == "unit-test"
    error_message = "The name variable must win over a Name key supplied in tags."
  }

  assert {
    condition     = aws_instance.this.tags["Environment"] == "test"
    error_message = "User supplied tags must be preserved."
  }
}

run "public_ip_is_opt_in" {
  command = plan

  variables {
    associate_public_ip_address = true
  }

  assert {
    condition     = aws_instance.this.associate_public_ip_address == true
    error_message = "Callers must still be able to opt in to a public IP."
  }
}

run "rejects_invalid_ami_id" {
  command = plan

  variables {
    ami = "ubuntu-latest"
  }

  expect_failures = [var.ami]
}

run "rejects_invalid_root_volume_type" {
  command = plan

  variables {
    root_volume_type = "gp4"
  }

  expect_failures = [var.root_volume_type]
}

run "rejects_out_of_range_root_volume_size" {
  command = plan

  variables {
    root_volume_size = 0
  }

  expect_failures = [var.root_volume_size]
}

run "rejects_root_volume_size_above_max" {
  command = plan

  variables {
    root_volume_size = 16385
  }

  expect_failures = [var.root_volume_size]
}

run "rejects_io1_root_volume_without_iops" {
  command = plan

  variables {
    root_volume_type = "io1"
  }

  expect_failures = [aws_instance.this]
}

run "accepts_io1_root_volume_with_iops" {
  command = plan

  variables {
    root_volume_type = "io1"
    root_volume_iops = 100
  }

  assert {
    condition     = aws_instance.this.root_block_device[0].iops == 100
    error_message = "The configured IOPS value must be passed through to the root volume."
  }
}

run "rejects_throughput_on_non_gp3_volume" {
  command = plan

  variables {
    root_volume_type       = "gp2"
    root_volume_throughput = 125
  }

  expect_failures = [aws_instance.this]
}

run "accepts_multiple_optional_flags_together" {
  command = plan

  variables {
    key_name                    = "ops-keypair"
    security_group_ids          = ["sg-0123456789abcdef0", "sg-0fedcba9876543210"]
    monitoring                  = true
    associate_public_ip_address = true
    subnet_id                   = "subnet-0abc123"
  }

  assert {
    condition     = aws_instance.this.key_name == "ops-keypair"
    error_message = "The key_name must be applied even when other optional flags are also set."
  }

  assert {
    condition     = length(aws_instance.this.vpc_security_group_ids) == 2
    error_message = "All supplied security group IDs must be applied together with the other optional flags."
  }

  assert {
    condition     = aws_instance.this.monitoring == true
    error_message = "Detailed monitoring must be honored alongside the other optional flags."
  }

  assert {
    condition     = aws_instance.this.associate_public_ip_address == true
    error_message = "The public IP opt-in must be honored alongside the other optional flags."
  }
}

run "initial_apply" {
  command = apply

  variables {
    name       = "unit-test"
    ami        = "ami-0abcdef1234567890"
    monitoring = false
  }

  assert {
    condition     = aws_instance.this.monitoring == false
    error_message = "The instance must start with monitoring disabled."
  }
}

run "update_monitoring_in_place" {
  command = apply

  variables {
    name       = "unit-test"
    ami        = "ami-0abcdef1234567890"
    monitoring = true
  }

  assert {
    condition     = aws_instance.this.monitoring == true
    error_message = "Enabling monitoring on an already-applied instance must update it in place rather than being silently ignored."
  }
}
