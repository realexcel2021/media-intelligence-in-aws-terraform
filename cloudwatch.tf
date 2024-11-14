resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_status_red_alarm" {
  alarm_name          = "lambdaeskibanaStatusRedAlarm91243293"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "At least one primary shard and its replicas are not allocated to a node."
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_status_yellow_alarm" {
  alarm_name          = "lambdaeskibanaStatusYellowAlarm7E7220A7"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "At least one replica shard is not allocated to a node."
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_free_storage_space_too_low_alarm" {
  alarm_name          = "lambdaeskibanaFreeStorageSpaceTooLowAlarm8BBE4782"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "A node in your cluster is down to 20 GiB of free storage space."
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Minimum"
  threshold           = 20000
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_index_writes_blocked_too_high_alarm" {
  alarm_name          = "lambdaeskibanaIndexWritesBlockedTooHighAlarm4D765E59"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "Your cluster is blocking write requests."
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_automated_snapshot_failure_too_high_alarm" {
  alarm_name          = "lambdaeskibanaAutomatedSnapshotFailureTooHighAlarm8522904F"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "An automated snapshot failed. This failure is often the result of a red cluster health status."
  metric_name         = "AutomatedSnapshotFailure"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_cpu_utilization_too_high_alarm" {
  alarm_name          = "lambdaeskibanaCPUUtilizationTooHighAlarm7DF33890"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  alarm_description   = "100% CPU utilization is not uncommon, but sustained high usage is problematic. Consider using larger instance types or adding instances."
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = 900
  statistic           = "Average"
  threshold           = 80
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_jvm_memory_pressure_too_high_alarm" {
  alarm_name          = "lambdaeskibanaJVMMemoryPressureTooHighAlarm7692308C"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "Average JVM memory pressure over last 15 minutes too high. Consider scaling vertically."
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = 900
  statistic           = "Average"
  threshold           = 80
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_master_cpu_utilization_too_high_alarm" {
  alarm_name          = "lambdaeskibanaMasterCPUUtilizationTooHighAlarmFC39CE30"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  alarm_description   = "Average CPU utilization over last 45 minutes too high. Consider using larger instance types for your dedicated master nodes."
  metric_name         = "MasterCPUUtilization"
  namespace           = "AWS/ES"
  period              = 900
  statistic           = "Average"
  threshold           = 50
}

resource "aws_cloudwatch_metric_alarm" "lambdaeskibana_master_jvm_memory_pressure_too_high_alarm" {
  alarm_name          = "lambdaeskibanaMasterJVMMemoryPressureTooHighAlarm1F9512ED"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_description   = "Average JVM memory pressure over last 15 minutes too high. Consider scaling vertically."
  metric_name         = "MasterJVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = 900
  statistic           = "Average"
  threshold           = 50
}
