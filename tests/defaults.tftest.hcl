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
