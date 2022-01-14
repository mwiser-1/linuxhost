# resource "observe_monitor" "sysctl_low_max_files" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Sysctl Low Max Files")
# 
#   inputs = {
#     "linux_sysctl_fs_metrics" = observe_dataset.linux_sysctl_fs_metrics.oid
#   }
# 
#   stage {
#     input    = "linux_sysctl_fs_metrics"
#     pipeline = <<-EOF
#       filter field = "file-max"
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
#       compare_values   = [ 1024 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
