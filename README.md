# terraform-aws-ec2

Terraform module that manages a single [Amazon EC2](https://aws.amazon.com/ec2/)
instance with an encrypted gp3 root volume and IMDSv2 required by default.

## Usage

```hcl
module "ec2" {
  source = "github.com/cybercapybara/terraform-aws-ec2"

  name          = "prod-app"
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.small"
  subnet_id     = "subnet-0abc123"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                          | Description                                                          | Type           | Default       | Required |
|-------------------------------|----------------------------------------------------------------------|----------------|---------------|:--------:|
| `name`                        | Name tag applied to the instance.                                   | `string`       | n/a           |   yes    |
| `ami`                         | AMI ID to launch the instance from.                                 | `string`       | n/a           |   yes    |
| `instance_type`               | EC2 instance type.                                                  | `string`       | `"t3.micro"`  |    no    |
| `subnet_id`                   | Subnet to launch the instance into. Null uses the default subnet.   | `string`       | `null`        |    no    |
| `key_name`                    | EC2 key pair to associate with the instance.                        | `string`       | `null`        |    no    |
| `security_group_ids`          | Security group IDs to attach to the instance.                       | `list(string)` | `[]`          |    no    |
| `associate_public_ip_address` | Whether to associate a public IP address.                           | `bool`         | `false`       |    no    |
| `monitoring`                  | Whether to enable detailed CloudWatch monitoring.                   | `bool`         | `false`       |    no    |
| `user_data`                   | User data script to run at instance launch.                         | `string`       | `null`        |    no    |
| `root_volume_type`            | Type of the root EBS volume.                                        | `string`       | `"gp3"`       |    no    |
| `root_volume_size`            | Size of the root EBS volume in GiB.                                 | `number`       | `8`           |    no    |
| `root_volume_encrypted`       | Whether the root EBS volume is encrypted.                           | `bool`         | `true`        |    no    |
| `tags`                        | Tags applied to the instance.                                       | `map(string)`  | `{}`          |    no    |

## Outputs

| Name                | Description                                         |
|---------------------|-----------------------------------------------------|
| `id`                | ID of the instance.                                 |
| `arn`               | ARN of the instance.                                |
| `private_ip`        | Private IPv4 address of the instance.               |
| `public_ip`         | Public IPv4 address of the instance, if assigned.   |
| `availability_zone` | Availability zone the instance runs in.             |

## License

[MIT](LICENSE)
