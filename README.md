# terraform-aws-ec2

Terraform module that manages a single [Amazon EC2](https://aws.amazon.com/ec2/)
instance with an encrypted gp3 root volume and IMDSv2 required by default.

## Usage

```hcl
module "ec2" {
  source = "github.com/moveeeax/terraform-aws-ec2?ref=v1.0.0"

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
| `user_data`                   | User data script to run at instance launch. Sensitive.              | `string`       | `null`        |    no    |
| `root_volume_type`            | Type of the root EBS volume. One of `gp2`, `gp3`, `io1`, `io2`, `standard`. | `string` | `"gp3"`  |    no    |
| `root_volume_size`            | Size of the root EBS volume in GiB (1–16384).                       | `number`       | `8`           |    no    |
| `root_volume_encrypted`       | Whether the root EBS volume is encrypted.                           | `bool`         | `true`        |    no    |
| `root_volume_iops`            | Provisioned IOPS for the root volume. Required when `root_volume_type` is `io1` or `io2`; optional tuning for `gp3`. | `number` | `null` |    no    |
| `root_volume_throughput`      | Throughput (MiB/s) for the root volume. Only applies to `gp3`.      | `number`       | `null`        |    no    |
| `tags`                        | Tags applied to the instance.                                       | `map(string)`  | `{}`          |    no    |

## Outputs

| Name                | Description                                         |
|---------------------|-----------------------------------------------------|
| `id`                | ID of the instance.                                 |
| `arn`               | ARN of the instance.                                |
| `private_ip`        | Private IPv4 address of the instance.               |
| `public_ip`         | Public IPv4 address of the instance, if assigned.   |
| `availability_zone` | Availability zone the instance runs in.             |

## A note on `user_data`

`user_data` is declared `sensitive`, so Terraform redacts it from plan output and
CI logs. That is not the same as keeping it secret: EC2 stores user data
unencrypted, it lands in the instance metadata service, and any process on the
instance can read it. Fetch real secrets at boot from SSM Parameter Store or
Secrets Manager instead of baking them into the launch script.

## A note on `root_volume_type`

AWS has no default IOPS for `io1`/`io2` volumes, so selecting either of those
types without also setting `root_volume_iops` fails at plan time with a clear
error instead of failing later during `apply`. `root_volume_throughput` only
applies to `gp3` and is likewise rejected at plan time if set alongside any
other volume type.

## Development

The module ships a [`terraform test`](tests) suite that runs against a mocked
AWS provider, so it needs no credentials and no network:

```sh
terraform init -backend=false
terraform test
```

The test suite requires Terraform or OpenTofu >= 1.7 for `mock_provider`; the
module itself still supports >= 1.5.

## License

[MIT](LICENSE)
