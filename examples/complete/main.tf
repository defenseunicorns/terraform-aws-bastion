
resource "random_id" "default" {
  byte_length = 2
}

locals {
  # Add randomness to names to avoid collisions when multiple users are using this example
  vpc_name     = "${var.name_prefix}-${lower(random_id.default.hex)}"
  bastion_name = "${var.name_prefix}-bastion-${lower(random_id.default.hex)}"
}

module "vpc" {
  # checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash" -- We've decided to use tags rather than a hash
  source = "git::https://github.com/defenseunicorns/terraform-aws-vpc.git?ref=v0.1.12"

  name                  = local.vpc_name
  vpc_cidr              = "10.200.0.0/16"
  secondary_cidr_blocks = ["100.64.0.0/16"] # Used for optimizing IP address usage by pods in an EKS cluster. See https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/
  azs                   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  intra_subnets         = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]
  single_nat_gateway    = true
  enable_nat_gateway    = true
  private_subnet_tags = {
    # Needed if you are deploying EKS v1.14 or earlier to this VPC. Not needed for EKS v1.15+.
    "kubernetes.io/cluster/my-cluster" = "owned"
    # Needed if you are using EKS with the AWS Load Balancer Controller v2.1.1 or earlier. Not needed if you are using a version of the Load Balancer Controller later than v2.1.1.
    "kubernetes.io/cluster/my-cluster" = "shared"
    # Needed if you are deploying EKS and load balancers to private subnets.
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    # Needed if you are deploying EKS and load balancers to public subnets. Not needed if you are only using private subnets for the EKS cluster.
    "kubernetes.io/role/elb" = 1
  }
  intra_subnet_tags = {
    "foo" = "bar"
  }
  create_database_subnet_group      = true
  instance_tenancy                  = "default"
  vpc_flow_log_permissions_boundary = var.iam_role_permissions_boundary
  tags                              = var.tags
}

data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*x86_64-gp2"]
  }

  owners = ["amazon"]
}

# This is created in the example and not maintained by the module. The module will read in with user data if it exists.
resource "aws_ssm_parameter" "cloudwatch_configuration_file" { # Create a cloudwatch agent configuration file that will be used to configure the cloudwatch agent on the bastion host
  # checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK" -- There is no sensitive data in this SSM parameter

  name = "AmazonCloudWatch-linux-${local.bastion_name}"
  type = "SecureString"

  value = jsonencode({
    "agent" : {
      "metrics_collection_interval" : var.cloudwatch_log_retention_days,
      "run_as_user" : "root"
    },
    "logs" : {
      "logs_collected" : {
        "files" : {
          "collect_list" : [
            {
              "file_path" : "/root/.bash_history",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "command-history/root-user/{instance_id}", # {instance_id} natively set by agent
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/home/ec2-user/.bash_history",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "command-history/ec2-user/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/home/ssm-user/.bash_history",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "command-history/ssm-user/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/amazon/ssm/amazon-ssm-agent.log",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "logins/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/messages",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/boot.log*",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/secure",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/messages",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/cron*",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/cloud-init-output.log",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
            {
              "file_path" : "/var/log/dmesg",
              "log_group_name" : var.global_cloud_watch_log_group_name,
              "log_stream_name" : "Syslog/{instance_id}",
              "retention_in_days" : var.cloudwatch_log_retention_days
            },
          ]
        }
      }
    },
    "metrics" : {
      "aggregation_dimensions" : [
        [
          "InstanceId"
        ]
      ],

      "metrics_collected" : {
        "collectd" : {
          "metrics_aggregation_interval" : var.cloudwatch_log_retention_days
        },
        "cpu" : {
          "measurement" : [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval" : var.cloudwatch_log_retention_days,
          "resources" : [
            "*"
          ],
          "totalcpu" : false
        },
        "disk" : {
          "measurement" : [
            "used_percent",
            "inodes_free"
          ],
          "metrics_collection_interval" : var.cloudwatch_log_retention_days,
          "resources" : [
            "*"
          ]
        },
        "diskio" : {
          "measurement" : [
            "io_time"
          ],
          "metrics_collection_interval" : var.cloudwatch_log_retention_days,
          "resources" : [
            "*"
          ]
        },
        "mem" : {
          "measurement" : [
            "mem_used_percent"
          ],
          "metrics_collection_interval" : var.cloudwatch_log_retention_days
        },
        "statsd" : {
          "metrics_aggregation_interval" : var.cloudwatch_log_retention_days,
          "metrics_collection_interval" : 10,
          "service_address" : ":8125"
        },
        "swap" : {
          "measurement" : [
            "swap_used_percent"
          ],
          "metrics_collection_interval" : var.cloudwatch_log_retention_days
        }
      }
    }
  })
}

module "bastion" {
  source = "../.."

  enable_bastion_terraform_permissions = true

  ami_id        = data.aws_ami.amazonlinux2.id
  instance_type = var.bastion_instance_type
  root_volume_config = {
    volume_type = "gp3"
    volume_size = "20"
    encrypted   = true
  }
  name             = local.bastion_name
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.private_subnets[0]
  region           = var.region
  ssh_user         = var.bastion_ssh_user
  ssh_password     = var.bastion_ssh_password
  assign_public_ip = false
  private_ip       = var.private_ip != "" ? var.private_ip : null

  tenancy              = var.bastion_tenancy
  zarf_version         = var.zarf_version
  permissions_boundary = var.iam_role_permissions_boundary

  enable_log_to_cloudwatch = true
  # cloudwatch_log_group_name defaults to /ssm/bastion-session-logs
  # cloudwatch_log_group_name = "my-cloudwatch-log-group"

  tags = var.tags
}
