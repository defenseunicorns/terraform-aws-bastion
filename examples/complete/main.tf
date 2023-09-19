data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

resource "random_id" "default" {
  byte_length = 2
}

locals {
  # Add randomness to names to avoid collisions when multiple users are using this example
  vpc_name                       = "${var.name_prefix}-${lower(random_id.default.hex)}"
  bastion_name                   = "${var.name_prefix}-bastion-${lower(random_id.default.hex)}"
  access_log_bucket_name_prefix  = "${var.name_prefix}-accesslog-${lower(random_id.default.hex)}"
  session_log_bucket_name_prefix = "${var.name_prefix}-bastionsessionlog-${lower(random_id.default.hex)}"
  kms_key_alias_name_prefix      = "alias/${var.name_prefix}-${lower(random_id.default.hex)}"
  access_log_sqs_queue_name      = "${var.name_prefix}-accesslog-access-${lower(random_id.default.hex)}"
}

module "vpc" {
  # checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash" -- We've decided to use tags rather than a hash
  source = "git::https://github.com/defenseunicorns/terraform-aws-uds-vpc.git?ref=v0.0.5"

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

# Create a KMS key and corresponding alias. This KMS key will be used whenever encryption is needed in creating this infrastructure deployment
resource "aws_kms_key" "default" {
  description             = "SSM Key"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_access.json
  tags                    = var.tags
  multi_region            = true
}

resource "aws_kms_alias" "default" {
  name_prefix   = local.kms_key_alias_name_prefix
  target_key_id = aws_kms_key.default.key_id
}

# Create custom policy for KMS
data "aws_iam_policy_document" "kms_access" {
  # checkov:skip=CKV_AWS_111: todo reduce perms on key
  # checkov:skip=CKV_AWS_109: todo be more specific with resources
  # checkov:skip=CKV_AWS_356: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions" -- TODO: Be more specific with resources
  statement {
    sid = "KMS Key Default"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*",
    ]

    resources = ["*"]
  }
  statement {
    sid = "CloudWatchLogsEncryption"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = ["*"]
  }
  statement {
    sid = "Cloudtrail KMS permissions"
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }
}


# Create S3 bucket for access logs with versioning, encryption, blocked public access enabled
resource "aws_s3_bucket" "access_log_bucket" {
  # checkov:skip=CKV_AWS_144: Cross region replication is overkill
  # checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled" -- This is the access logging bucket. Logging to the logging bucket would cause an infinite loop.
  bucket_prefix = local.access_log_bucket_name_prefix
  force_destroy = true
  tags          = var.tags

  lifecycle {
    precondition {
      condition     = length(local.access_log_bucket_name_prefix) <= 37
      error_message = "Bucket name prefixes may not be longer than 37 characters."
    }
  }
}

resource "aws_s3_bucket_versioning" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.default.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_log_bucket" {
  bucket                  = aws_s3_bucket.access_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_log_bucket" {
  bucket = aws_s3_bucket.access_log_bucket.id

  rule {
    id     = "delete_after_X_days"
    status = "Enabled"

    expiration {
      days = var.access_log_expire_days
    }
  }

  rule {
    id     = "abort_incomplete_multipart_upload"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_sqs_queue" "access_log_queue" {
  count                             = var.enable_sqs_events_on_access_log_access ? 1 : 0
  name                              = local.access_log_sqs_queue_name
  kms_master_key_id                 = aws_kms_key.default.arn
  kms_data_key_reuse_period_seconds = 300
  visibility_timeout_seconds        = 300

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSend",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:${data.aws_partition.current.partition}:sqs:*:*:${local.access_log_sqs_queue_name}",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.access_log_bucket.arn}" }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "access_log_bucket_notification" {
  count  = var.enable_sqs_events_on_access_log_access ? 1 : 0
  bucket = aws_s3_bucket.access_log_bucket.id

  queue {
    queue_arn = aws_sqs_queue.access_log_queue[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*x86_64-gp2"]
  }

  owners = ["amazon"]
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
  name                           = local.bastion_name
  vpc_id                         = module.vpc.vpc_id
  subnet_id                      = module.vpc.private_subnets[0]
  region                         = var.region
  access_logs_bucket_name        = aws_s3_bucket.access_log_bucket.id
  session_log_bucket_name_prefix = local.session_log_bucket_name_prefix
  kms_key_arn                    = aws_kms_key.default.arn
  ssh_user                       = var.bastion_ssh_user
  ssh_password                   = var.bastion_ssh_password
  assign_public_ip               = false
  enable_log_to_s3               = true
  enable_log_to_cloudwatch       = true
  private_ip                     = var.private_ip != "" ? var.private_ip : null

  tenancy              = var.bastion_tenancy
  zarf_version         = var.zarf_version
  permissions_boundary = var.iam_role_permissions_boundary
  tags                 = var.tags
}
