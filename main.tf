data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_ami" "from_filter" {
  count       = var.ami_id != "" ? 0 : 1
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }

  owners = [var.ami_canonical_owner]
}

data "aws_subnet" "subnet_by_name" {
  count = var.subnet_name != "" ? 1 : 0
  tags = {
    Name : var.subnet_name
  }
}

data "aws_kms_key" "default" {
  key_id = var.kms_key_arn
}

resource "aws_instance" "application" {
  #checkov:skip=CKV2_AWS_41: IAM role is created in the module
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.from_filter[0].id
  instance_type               = var.instance_type
  vpc_security_group_ids      = length(local.security_group_configs) > 0 ? aws_security_group.sg[*].id : var.security_group_ids
  user_data                   = var.user_data_override != null ? var.user_data_override : data.cloudinit_config.config.rendered
  iam_instance_profile        = local.role_name == "" ? null : aws_iam_instance_profile.bastion_ssm_profile.name
  ebs_optimized               = true
  associate_public_ip_address = var.assign_public_ip
  monitoring                  = true
  tenancy                     = var.tenancy
  private_ip                  = var.private_ip
  root_block_device {
    volume_size = var.root_volume_config.volume_size
    volume_type = var.root_volume_config.volume_type
    encrypted   = true
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  subnet_id = var.subnet_name != "" ? data.aws_subnet.subnet_by_name[0].id : var.subnet_id

  tags = merge(
    var.tags,
    var.bastion_instance_tags,
    { Name = var.name },
  )
}

resource "aws_network_interface_attachment" "attach" {
  count                = var.eni_attachment_config != null ? length(var.eni_attachment_config) : 0
  instance_id          = aws_instance.application.id
  network_interface_id = var.eni_attachment_config[count.index].network_interface_id
  device_index         = var.eni_attachment_config[count.index].device_index
}

# Optional Security Group
resource "aws_security_group" "sg" {
  # checkov:skip=CKV_AWS_23: "Ensure every security groups rule has a description" -- False positive
  count       = length(local.security_group_configs)
  name        = local.security_group_configs[count.index].name
  description = local.security_group_configs[count.index].description
  vpc_id      = local.security_group_configs[count.index].vpc_id

  # dynamic "ingress" {
  #   for_each = local.security_group_configs[count.index].ingress_rules

  #   content {
  #     from_port   = ingress.value.from_port
  #     to_port     = ingress.value.to_port
  #     protocol    = ingress.value.protocol
  #     cidr_blocks = ingress.value.cidr_blocks
  #     description = ingress.value.description
  #   }
  # }

  dynamic "egress" {
    for_each = local.security_group_configs[count.index].egress_rules

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
}

#####################################################
##################### user data #####################

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"

    content = templatefile("${path.module}/templates/user_data.sh.tpl",
      {
        aws_region                  = var.region
        ssh_user                    = var.ssh_user
        ssh_password                = var.ssh_password
        keys_update_frequency       = local.keys_update_frequency
        enable_hourly_cron_updates  = local.enable_hourly_cron_updates
        additional_user_data_script = var.additional_user_data_script
        ssm_enabled                 = var.ssm_enabled
        secrets_manager_secret_id   = var.secrets_manager_secret_id
        zarf_version                = var.zarf_version
        ssm_parameter_name          = var.name
        enable_log_to_cloudwatch    = var.enable_log_to_cloudwatch
      }
    )
  }
}

resource "aws_ebs_volume" "bastion_secondary_ebs_volume" {
  count             = var.enable_secondary_ebs_volume ? 1 : 0
  availability_zone = aws_instance.application.availability_zone
  size              = var.bastion_secondary_ebs_volume_size
  encrypted         = true
  tags              = var.tags
}

resource "aws_volume_attachment" "ebs_attachment" {
  count       = var.enable_secondary_ebs_volume ? 1 : 0
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.bastion_secondary_ebs_volume[0].id
  instance_id = aws_instance.application.id
}
