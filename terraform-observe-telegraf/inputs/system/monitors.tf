# resource "observe_monitor" "system_high_load" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "System High Load")
# 
#   inputs = {
#     "system_metrics" = observe_dataset.system_metrics.oid
#   }
# 
#   stage {
#     input    = "system_metrics"
#     pipeline = <<-EOF
#       filter field = "load5"
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
