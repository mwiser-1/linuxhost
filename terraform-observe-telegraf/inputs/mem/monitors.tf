# resource "observe_monitor" "memory_high_usage" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Memory High Usage")
# 
#   inputs = {
#     "mem_metrics" = observe_dataset.mem_metrics.oid
#   }
# 
#   stage {
#     input    = "mem_metrics"
#     pipeline = <<-EOF
#       filter field = "used_percent"
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
#       compare_values   = [ 90 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
# 
# resource "observe_monitor" "memory_low_available" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Memory Low Available")
# 
#   inputs = {
#     "mem_metrics" = observe_dataset.mem_metrics.oid
#   }
# 
#   stage {
#     input    = "mem_metrics"
#     pipeline = <<-EOF
#       filter field = "available"
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
#       compare_values   = [ 20971520 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
# 
# resource "observe_monitor" "memory_low_swap_free" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Memory Low Swap Free")
# 
#   inputs = {
#     "mem_metrics" = observe_dataset.mem_metrics.oid
#   }
# 
#   stage {
#     input    = "mem_metrics"
#     pipeline = <<-EOF
#       filter field = "swap_free"
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
#       compare_values   = [ 52428800 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
