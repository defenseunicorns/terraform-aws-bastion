variable "name_prefix" {
  description = "The prefix to use when naming all resources"
  type        = string
  default     = "ci"
  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "The name prefix cannot be more than 20 characters"
  }
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "iam_role_permissions_boundary" {
  description = "ARN of a permissions boundary policy to use when creating IAM roles"
  type        = string
  default     = null
}

variable "bastion_instance_type" {
  description = "value for the instance type of the EKS worker nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "bastion_ssh_user" {
  description = "The SSH user to use for the bastion"
  type        = string
  default     = "ec2-user"
}

variable "kms_key_deletion_window" {
  description = "Waiting period for scheduled KMS Key deletion. Can be 7-30 days."
  type        = number
  default     = 7
}

variable "bastion_ssh_password" {
  description = "The SSH password to use for the bastion if SSM authentication is used"
  type        = string
  default     = "my-password"
}

variable "bastion_tenancy" {
  description = "The tenancy of the bastion"
  type        = string
  default     = "default"
}

variable "zarf_version" {
  description = "The version of Zarf to use"
  type        = string
  default     = ""
}

variable "private_ip" {
  description = "The private IP address to assign to the bastion"
  type        = string
  default     = ""
}

variable "global_cloud_watch_log_group_name" {
  description = "The name of the global cloudwatch log group"
  type        = string
  default     = "global-logs"
}

variable "cloudwatch_log_retention_days" {
  description = "how long you want to keep the cloudwatch logs (in days)"
  type        = number
  default     = 30

}

variable "aws_kms_key_arn" {
  description = "arn for the key used for cloudwatch logs"
  type = string
}
