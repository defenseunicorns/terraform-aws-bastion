# Create a cloudwatch agent configuration file and log group
resource "aws_ssm_parameter" "cloudwatch_configuration_file" {
  # checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK" -- There is no sensitive data in this SSM parameter
  count = var.log_group_name != "" ? 1 : 0 # Creates the resource only if var.log_group_name is not empty

  name = "AmazonCloudWatch-linux-${ec2.instance.id}" # variablized for scalability
  type = "SecureString"

  value = jsonencode({
    "agent" : {
      "metrics_collection_interval" : 60,
      "run_as_user" : "root"
    },
    "logs" : {
      "logs_collected" : {
        "files" : {
          "collect_list" : [
            {
              "file_path" : "/root/.bash_history",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "command-history/root-user/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/home/ec2-user/.bash_history",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "command-history/ec2-user/${ec2.instance.id}",
              "retention_in_days" : 60
            },

            {
              "file_path" : "/var/log/secure",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "logins/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/home/ssm-user/.bash_history",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "command-history/ssm-user/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/messages",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/boot.log*",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/secure",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/messages",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/cron*",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/cloud-init-output.log",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
            },
            {
              "file_path" : "/var/log/dmesg",
              "log_group_name" : var.log_group_name,
              "log_stream_name" : "Syslog/${ec2.instance.id}",
              "retention_in_days" : 60
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
          "metrics_aggregation_interval" : 60
        },
        "cpu" : {
          "measurement" : [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "metrics_collection_interval" : 60,
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
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ]
        },
        "diskio" : {
          "measurement" : [
            "io_time"
          ],
          "metrics_collection_interval" : 60,
          "resources" : [
            "*"
          ]
        },
        "mem" : {
          "measurement" : [
            "mem_used_percent"
          ],
          "metrics_collection_interval" : 60
        },
        "statsd" : {
          "metrics_aggregation_interval" : 60,
          "metrics_collection_interval" : 10,
          "service_address" : ":8125"
        },
        "swap" : {
          "measurement" : [
            "swap_used_percent"
          ],
          "metrics_collection_interval" : 60
        }
      }
    }
  })
}