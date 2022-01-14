# resource "observe_monitor" "cpu_low_idle" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "CPU Low Idle")
# 
#   inputs = {
#     "cpu_metrics" = observe_dataset.cpu_metrics.oid
#   }
# 
#   stage {
#     input    = "cpu_metrics"
#     pipeline = <<-EOF
#       filter field = "usage_idle"
#     EOF
#   }
#   rule {
#     group_by         = "value"
#     group_by_columns = [
#       "host",
#       "datacenter",
#     ]
#     source_column    = "value"
#     threshold {
#       compare_function = "less"
#       compare_values   = [ 10 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
# 
# resource "observe_monitor" "cpu_high_iowait" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "CPU High I/O Wait")
# 
#   inputs = {
#     "cpu_metrics" = observe_dataset.cpu_metrics.oid
#   }
# 
#   stage {
#     input    = "cpu_metrics"
#     pipeline = <<-EOF
#       filter field = "usage_iowait"
#     EOF
#   }
#   rule {
#     group_by         = "value"
#     group_by_columns = [
#       "host",
#       "datacenter",
#     ]
#     source_column    = "value"
#     threshold {
#       compare_function = "greater"
#       compare_values   = [ 20 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
