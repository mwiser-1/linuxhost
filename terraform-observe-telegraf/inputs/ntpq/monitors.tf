# resource "observe_monitor" "ntpq_high_offset" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "NTPq High Offset")
# 
#   inputs = {
#     "ntpq_metrics" = observe_dataset.ntpq_metrics.oid
#   }
# 
#   stage {
#     input    = "ntpq_metrics"
#     pipeline = <<-EOF
#       filter field = "offset"
#       statsby value:min(value), groupby(host, datacenter, field, timestamp)
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
#       compare_values   = [ 5 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
