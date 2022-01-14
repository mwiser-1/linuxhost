# resource "observe_monitor" "processes_high" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Processes High")
# 
#   inputs = {
#     "processes_metrics" = observe_dataset.processes_metrics.oid
#   }
# 
#   stage {
#     input    = "processes_metrics"
#     pipeline = <<-EOF
#       filter field = "total"
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
#       compare_values   = [ 3000 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
# 
# resource "observe_monitor" "processes_high_running" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Processes High Running")
# 
#   inputs = {
#     "processes_metrics" = observe_dataset.processes_metrics.oid
#   }
# 
#   stage {
#     input    = "processes_metrics"
#     pipeline = <<-EOF
#       filter field = "running"
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
#       compare_values   = [ 300 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
