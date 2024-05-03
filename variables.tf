# Global Vars

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN to use for encryption"
}

### Bastion Module

variable "name" {
  type        = string
  description = "Name of Bastion"
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for Bastion"
  default     = "m5.large"
}

variable "ami_id" {
  type        = string
  description = "ID of AMI to use for Bastion"
  default     = ""
}

variable "allowed_public_ips" {
  type        = list(string)
  description = "List of public IPs or private IP (internal) of Software Defined Perimeter to allow SSH access from"
  default     = []
}

variable "private_ip" {
  type        = string
  description = "The private IP address to assign to the bastion"
  default     = null
}

variable "ami_name_filter" {
  type        = string
  description = "Filter for AMI using this name. Accepts wildcards"
  default     = ""
}

variable "ami_virtualization_type" {
  type        = string
  description = "Filter for AMI using this virtualization type"
  default     = ""
}

variable "ami_canonical_owner" {
  type        = string
  description = "Filter for AMI using this canonical owner ID"
  default     = null
}

variable "security_group_ids" {
  type        = list(any)
  description = "List of security groups to associate with instance"
  default     = []
}

variable "subnet_id" {
  type        = string
  description = "IDs of subnets to deploy the instance in"
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "Names of subnets to deploy the instance in"
  default     = ""
}

variable "policy_arns" {
  type        = list(string)
  description = "List of IAM policy ARNs to attach to the instance profile"
  default     = []
}

variable "policy_content" {
  type        = string
  description = "JSON IAM Policy body. Use this to add a custom policy to your instance profile (Optional)"
  default     = null
  validation {
    condition     = var.policy_content == null || try(jsondecode(var.policy_content), null) != null
    error_message = "The policy_content variable must be valid JSON."
  }
}

variable "root_volume_config" {
  type = object({
    volume_type = any
    volume_size = any
  })
  default = {
    volume_type = "gp3"
    volume_size = "20"
  }
}

variable "enable_secondary_ebs_volume" {
  description = "Enable the creation of a secondary EBS volume"
  type        = bool
  default     = false
}

variable "bastion_secondary_ebs_volume_size" {
  description = "value of the secondary EBS volume size in GB"
  type        = string
  default     = "70"
}

variable "assign_public_ip" {
  description = "Determines if an instance gets a public IP assigned at launch time"
  type        = bool
  default     = false
}

variable "eni_attachment_config" {
  description = "Optional list of enis to attach to instance"
  type = list(object({
    network_interface_id = string
    device_index         = string
  }))
  default = null
}

variable "permissions_boundary" {
  description = "(Optional) The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}

#####################################################
##################### user data #####################

variable "ssh_user" {
  description = "Username to use when accessing the instance using SSH"
  type        = string
  default     = "ec2-user"
}

variable "additional_user_data_script" {
  description = "Additional user data script to run on instance boot"
  type        = string
  default     = ""
}

variable "ssm_enabled" {
  description = "Enable SSM agent"
  type        = bool
  default     = true
}

variable "ssh_password" {
  description = "Password for SSH access if SSM authentication is enabled, optional"
  type        = string
  default     = ""
}

variable "secrets_manager_secret_id" {
  description = "The ID of the Secrets Manager secret for the bastion to pull from for SSH access if SSM authentication is enabled, optional"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "bastion_instance_tags" {
  description = "A map of tags to add to the bastion instance"
  type        = map(string)
  default     = {}
}

variable "enable_log_to_cloudwatch" {
  description = "Enable Session Manager to Log to CloudWatch Logs"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for storing SSM Session Logs"
  type        = string
  default     = "/ssm/session-logs"
}

variable "linux_shell_profile" {
  description = "The ShellProfile to use for linux based machines."
  default     = ""
  type        = string
}

variable "windows_shell_profile" {
  description = "The ShellProfile to use for windows based machines."
  default     = ""
  type        = string
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Valid values are 'default' or 'dedicated'."
  type        = string
  default     = "default"
}

variable "zarf_version" {
  description = "The version of Zarf to use"
  type        = string
  default     = ""
}

variable "enable_bastion_terraform_permissions" {
  description = "Enable Terraform permissions for Bastion"
  type        = bool
  default     = false
}

variable "user_data_override" {
  description = "Override the default module user data with your own. This will disable the default user data and use your own."
  type        = string
  default     = null
}
