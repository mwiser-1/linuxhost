# resource "observe_monitor" "disk_low_usage" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Disk Low Usage")
# 
#   inputs = {
#     "disk_metrics" = observe_dataset.disk_metrics.oid
#   }
# 
#   stage {
#     input    = "disk_metrics"
#     pipeline = <<-EOF
#       filter field = "used_percent"
#     EOF
#   }
#   rule {
#     group_by         = "value"
#     group_by_columns = [
#       "volume",
#       "host",
#       "datacenter",
#     ]
#     source_column    = "value"
#     threshold {
#       compare_function = "greater"
#       compare_values   = [ 80 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
# 
# resource "observe_monitor" "disk_high_usage" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Disk High Usage")
# 
#   inputs = {
#     "disk_metrics" = observe_dataset.disk_metrics.oid
#   }
# 
#   stage {
#     input    = "disk_metrics"
#     pipeline = <<-EOF
#       filter field = "used_percent"
#     EOF
#   }
#   rule {
#     group_by         = "value"
#     group_by_columns = [
#       "volume",
#       "host",
#       "datacenter",
#     ]
#     source_column    = "value"
#     threshold {
#       compare_function = "less"
#       compare_values   = [ 20 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
# 
# resource "observe_monitor" "disk_free_inodes_low" {
#   workspace = var.workspace.oid
#   name      = format(var.name_format, "Disk Free Inodes Low")
# 
#   inputs = {
#     "disk_metrics" = observe_dataset.disk_metrics.oid
#   }
# 
#   stage {
#     input    = "disk_metrics"
#     alias    = "inodes_total"
#     pipeline = <<-EOF
#       filter field = "inodes_total"
#     EOF
#   }
#   stage {
#     input    = "disk_metrics"
#     pipeline = <<-EOF
#       filter field = "inodes_free"
#       join timestamp=@inodes_total.timestamp, volume=@inodes_total.volume, host=@inodes_total.host, datacenter=@inodes_total.datacenter, inodes_total:@inodes_total.value
#       make_col field:"inodes_free_percent", value:float64(value/inodes_total) * 100
#       drop_col inodes_total
#     EOF
#   }
#   rule {
#     group_by         = "value"
#     group_by_columns = [
#       "volume",
#       "host",
#       "datacenter",
#     ]
#     source_column    = "value"
#     threshold {
#       compare_function = "less"
#       compare_values   = [ 20 ]
#       lookback_time    = "5m0s"
#     }
#   }
#   notification_spec {
#     merge = "separate"
#   }
# }
