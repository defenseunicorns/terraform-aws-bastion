# Bastion Module

This repository contains Terraform configuration files that create an AWS EC2 instance using a hardened AMI, assigns it to a security group, and attaches it to a subnet. This is for secure access into a private subnet via a hardened device. It also creates an SSH key pair for the instance and an IAM instance profile with an optional role. Additionally, it creates an optional KMS key and security group for event queue.

## Examples

To view examples for how you can leverage this Bastion, please see the [examples](https://github.com/defenseunicorns/terraform-aws-bastion/tree/main/examples) directory.

<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.bastion_secondary_ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.bastion_ssm_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terraform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bastion_ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion-ssm-aws-efs-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion-ssm-aws-ssm-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion-ssm-s3-cwl-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.ebs_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.from_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy.AmazonElasticFileSystemFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.CloudWatchLogsFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.subnet_by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_user_data_script"></a> [additional\_user\_data\_script](#input\_additional\_user\_data\_script) | Additional user data script to run on instance boot | `string` | `""` | no |
| <a name="input_allowed_public_ips"></a> [allowed\_public\_ips](#input\_allowed\_public\_ips) | List of public IPs or private IP (internal) of Software Defined Perimeter to allow SSH access from | `list(string)` | `[]` | no |
| <a name="input_ami_canonical_owner"></a> [ami\_canonical\_owner](#input\_ami\_canonical\_owner) | Filter for AMI using this canonical owner ID | `string` | `null` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | ID of AMI to use for Bastion | `string` | `""` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | Filter for AMI using this name. Accepts wildcards | `string` | `""` | no |
| <a name="input_ami_virtualization_type"></a> [ami\_virtualization\_type](#input\_ami\_virtualization\_type) | Filter for AMI using this virtualization type | `string` | `""` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Determines if an instance gets a public IP assigned at launch time | `bool` | `false` | no |
| <a name="input_bastion_instance_tags"></a> [bastion\_instance\_tags](#input\_bastion\_instance\_tags) | A map of tags to add to the bastion instance | `map(string)` | `{}` | no |
| <a name="input_bastion_secondary_ebs_volume_size"></a> [bastion\_secondary\_ebs\_volume\_size](#input\_bastion\_secondary\_ebs\_volume\_size) | value of the secondary EBS volume size in GB | `string` | `"70"` | no |
| <a name="input_enable_bastion_terraform_permissions"></a> [enable\_bastion\_terraform\_permissions](#input\_enable\_bastion\_terraform\_permissions) | Enable Terraform permissions for Bastion | `bool` | `false` | no |
| <a name="input_enable_log_to_cloudwatch"></a> [enable\_log\_to\_cloudwatch](#input\_enable\_log\_to\_cloudwatch) | Enable Session Manager to Log to CloudWatch Logs | `bool` | `false` | no |
| <a name="input_enable_secondary_ebs_volume"></a> [enable\_secondary\_ebs\_volume](#input\_enable\_secondary\_ebs\_volume) | Enable the creation of a secondary EBS volume | `bool` | `false` | no |
| <a name="input_eni_attachment_config"></a> [eni\_attachment\_config](#input\_eni\_attachment\_config) | Optional list of enis to attach to instance | <pre>list(object({<br/>    network_interface_id = string<br/>    device_index         = string<br/>  }))</pre> | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for Bastion | `string` | `"m5.large"` | no |
| <a name="input_max_ssh_sessions"></a> [max\_ssh\_sessions](#input\_max\_ssh\_sessions) | Maximum number of ssh connections that are allowed | `number` | `1` | no |
| <a name="input_max_ssm_connections"></a> [max\_ssm\_connections](#input\_max\_ssm\_connections) | Maximum number of simultaneous connections that SSM will allow | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of Bastion | `string` | n/a | yes |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of IAM policy ARNs to attach to the instance profile | `list(string)` | `[]` | no |
| <a name="input_policy_content"></a> [policy\_content](#input\_policy\_content) | JSON IAM Policy body. Use this to add a custom policy to your instance profile (Optional) | `string` | `null` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | The private IP address to assign to the bastion | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_volume_config"></a> [root\_volume\_config](#input\_root\_volume\_config) | n/a | <pre>object({<br/>    volume_type = any<br/>    volume_size = any<br/>  })</pre> | <pre>{<br/>  "volume_size": "20",<br/>  "volume_type": "gp3"<br/>}</pre> | no |
| <a name="input_secrets_manager_secret_id"></a> [secrets\_manager\_secret\_id](#input\_secrets\_manager\_secret\_id) | The ID of the Secrets Manager secret for the bastion to pull from for SSH access if SSM authentication is enabled, optional | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security groups to associate with instance | `list(any)` | `[]` | no |
| <a name="input_ssh_password"></a> [ssh\_password](#input\_ssh\_password) | Password for SSH access if SSM authentication is enabled, optional | `string` | `""` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | Username to use when accessing the instance using SSH | `string` | `"ec2-user"` | no |
| <a name="input_ssm_enabled"></a> [ssm\_enabled](#input\_ssm\_enabled) | Enable SSM agent | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | IDs of subnets to deploy the instance in | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Names of subnets to deploy the instance in | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Valid values are 'default' or 'dedicated'. | `string` | `"default"` | no |
| <a name="input_terminate_oldest_ssm_connection_first"></a> [terminate\_oldest\_ssm\_connection\_first](#input\_terminate\_oldest\_ssm\_connection\_first) | Determines how the SSM connections will be terminated. If true then oldest connection will terminate first. Defaults to false | `bool` | `false` | no |
| <a name="input_uds_cli_version"></a> [uds\_cli\_version](#input\_uds\_cli\_version) | The version of UDS CLI to use | `string` | `"v0.11.0"` | no |
| <a name="input_user_data_override"></a> [user\_data\_override](#input\_user\_data\_override) | Override the default module user data with your own. This will disable the default user data and use your own. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | n/a | yes |
| <a name="input_zarf_version"></a> [zarf\_version](#input\_zarf\_version) | The version of Zarf to use | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_role_arn"></a> [bastion\_role\_arn](#output\_bastion\_role\_arn) | Bastion Role ARN |
| <a name="output_bastion_role_name"></a> [bastion\_role\_name](#output\_bastion\_role\_name) | Bastion Role Name |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Instance Id |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | Primary Network Interface Id |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | Private DNS |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP |
| <a name="output_region"></a> [region](#output\_region) | Region the bastion was deployed to |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security Group Ids |
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
