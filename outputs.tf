output "this_availability_zone" {
  description = "The zone id of the instance."
  value       = alicloud_instance.instance.*.availability_zone
}

// Output the IDs of the ECS instances created
output "this_instance_id" {
  description = "The instance ids."
  value       = alicloud_instance.instance.*.id
}

output "this_instance_name" {
  description = "The instance names."
  value       = alicloud_instance.instance.*.instance_name
}

output "this_instance_tags" {
  description = "The tags for the instance."
  value       = alicloud_instance.instance.*.tags
}

# VSwitch  ID
output "this_vswitch_id" {
  description = "The vswitch id in which the instance."
  value       = alicloud_instance.instance.*.vswitch_id
}

# Security Group outputs
output "this_security_group_ids" {
  description = "The security group ids in which the instance."
  value       = alicloud_instance.instance.*.security_groups
}

# Key pair outputs
output "this_key_name" {
  description = "The key name of the instance."
  value       = alicloud_instance.instance.*.key_name
}

output "this_role_name" {
  description = "The role name of the instance."
  value       = alicloud_instance.instance.*.role_name
}

output "this_private_ip" {
  description = "The private ip of the instance."
  value       = alicloud_instance.instance.*.private_ip
}

output "this_public_ip" {
  description = "The public ip of the instance."
  value       = alicloud_instance.instance.*.public_ip
}

output "this_host_name" {
  description = "The host name of the instance."
  value       = alicloud_instance.instance.*.host_name
}