resource "observe_dataset" "host" {
  workspace   = var.workspace.oid
  name        = format(var.resource_name_format, "Host")
  icon_url    = "server"
  description = "Host resource generated from OSQuery system_info events"

  inputs = {
    "event" = observe_dataset.events[0].oid
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      filter name = "system_info"
      make_col
        host:string(tags.host),
        datacenter:string(tags.datacenter)
      make_col
        appgroup:string(tags.appgroup),
        instance_id:string(tags.ec2_instance_id),
        instance_type:string(tags.ec2_instance_type),
        availability_zone:string(tags.ec2_az)
      make_resource options(expiry:5m),
        appgroup, instance_id, instance_type,availability_zone,
        primarykey(host, datacenter)
      set_label host
    EOF
  }
}
