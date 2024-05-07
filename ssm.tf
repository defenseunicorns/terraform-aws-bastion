resource "aws_ssm_document" "session_manager_prefs" {
  name            = "${var.name}-SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"
  tags            = var.tags


  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      runAsEnabled = false
      kmsKeyId     = data.aws_kms_key.default.id
      shellProfile = {
        linux   = var.linux_shell_profile == "" ? var.linux_shell_profile : ""
        windows = var.windows_shell_profile == "" ? var.windows_shell_profile : ""
      }

      # send logs to cloudwatch in real time, needs a valid cloudwatch_log_group_name
      cloudWatchStreamingEnabled  = var.enable_log_to_cloudwatch ? true : false
      cloudWatchLogGroupName      = var.enable_log_to_cloudwatch ? var.cloudwatch_log_group_name : ""
      cloudWatchEncryptionEnabled = var.enable_log_to_cloudwatch && var.cloud_watch_encryption_enabled ? true : false
    }
  })
}
