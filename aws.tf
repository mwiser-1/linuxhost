resource "observe_link" "instance_ec2" {
  workspace = var.workspace.oid
  source    = module.osquery.host.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key

  for_each = merge(
    var.ec2 != null ? {
      "Instance" = {
        target = var.ec2.instance.oid
        fields = ["instance_id:instanceId"]
      }
    } : {},
  )
}
