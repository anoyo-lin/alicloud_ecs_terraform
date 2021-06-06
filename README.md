# alicloud ecs provisioning by terraform
1. IAM creation
 - user & access key
 - admin policy
 - user group
 - role for ecs instance
2. KMS encryption creation
 - customer master key for symmetric encryption
 - encryption by openapi [alicloud openApi](https://next.api.aliyun.com/api/Kms/2016-01-20/DescribeRegions?params={})
 - or encrypt the plain text by python client
3. ecs instance creation
 - assign the instance role & instance profile
 - password decryption at run time
 - userdata with necessary work handling.

## Note
please create your dev.tfvars by following the dev.tfvars.template

## reference
[alicloud ecs module](https://github.com/terraform-alicloud-modules/terraform-alicloud-ecs-instance)

### result
```
$ ./terraform.sh dev apply
alicloud_ram_role.role: Refreshing state... [id=gene-test-role]
alicloud_key_pair.publickey: Refreshing state... [id=terraform-20210606072537621100000002]
alicloud_ram_user.user: Refreshing state... [id=220096722964331188]
alicloud_ram_group.group: Refreshing state... [id=gene-test-group]
alicloud_vpc.vpc: Refreshing state... [id=vpc-0jlizxefptq5hbzct1x8v]
alicloud_ram_policy.policy: Refreshing state... [id=gene-test-admin-policy]
alicloud_ram_group_membership.membership: Refreshing state... [id=gene-test-group]
alicloud_ram_access_key.ak: Refreshing state... [id=LTAI5tPxcx1xqRTYFezCyR7z]
alicloud_ram_role_policy_attachment.attach: Refreshing state... [id=role:gene-test-admin-policy:Custom:gene-test-role]
alicloud_ram_user_policy_attachment.attach: Refreshing state... [id=user:gene-test-admin-policy:Custom:gene-test-user]
alicloud_ram_group_policy_attachment.attach: Refreshing state... [id=group:gene-test-admin-policy:Custom:gene-test-group]
alicloud_vswitch.vswitch: Refreshing state... [id=vsw-0jlwjdkk5rfu8l6ietewv]
alicloud_security_group.group: Refreshing state... [id=sg-0jld8komf3dlzv23ytn1]
alicloud_security_group_rule.allow_all_tcp: Refreshing state... [id=sg-0jld8komf3dlzv23ytn1:ingress:tcp:1/65535:intranet:0.0.0.0/0:accept:1]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # alicloud_instance.instance will be created
  + resource "alicloud_instance" "instance" {
      + availability_zone             = "cn-wulanchabu-c"
      + credit_specification          = (known after apply)
      + deletion_protection           = false
      + dry_run                       = false
      + host_name                     = "gene-test"
      + id                            = (known after apply)
      + image_id                      = "ubuntu_18_04_x64_20G_alibase_20210420.vhd"
      + instance_charge_type          = "PostPaid"
      + instance_name                 = "gene-test-instance"
      + instance_type                 = "ecs.t6-c1m2.large"
      + internet_charge_type          = "PayByTraffic"
      + internet_max_bandwidth_in     = (known after apply)
      + internet_max_bandwidth_out    = 5
      + key_name                      = "terraform-20210606072537621100000002"
      + private_ip                    = (known after apply)
      + public_ip                     = (known after apply)
      + role_name                     = "gene-test-role"
      + security_groups               = [
          + "sg-0jld8komf3dlzv23ytn1",
        ]
      + spot_strategy                 = "NoSpot"
      + status                        = "Running"
      + subnet_id                     = (known after apply)
      + system_disk_category          = "cloud_efficiency"
      + system_disk_description       = "gene-test-system-disk-description"
      + system_disk_name              = "gene-test-system-disk"
      + system_disk_performance_level = (known after apply)
      + system_disk_size              = 40
      + user_data                     = <<-EOT
            #!/bin/bash
            echo "Hello gene-test"
        EOT
      + volume_tags                   = (known after apply)
      + vswitch_id                    = "vsw-0jlwjdkk5rfu8l6ietewv"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + this_instance_id = [
      + (known after apply),
    ]
  + this_private_ip  = [
      + (known after apply),
    ]
  + this_public_ip   = [
      + (known after apply),
    ]

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

alicloud_instance.instance: Creating...
alicloud_instance.instance: Still creating... [10s elapsed]
alicloud_instance.instance: Creation complete after 15s [id=i-0jl9vl31opuwwkxy06sg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

this_availability_zone = [
  "cn-wulanchabu-c",
]
this_host_name = [
  "gene-test",
]
this_instance_id = [
  "i-0jl9vl31opuwwkxy06sg",
]
this_instance_name = [
  "gene-test-instance",
]
this_instance_tags = [
  tomap(null) /* of string */,
]
this_key_name = [
  "terraform-20210606072537621100000002",
]
this_private_ip = [
  "172.16.1.230",
]
this_public_ip = [
  "153d66f3-28d5-4cb1-9fac-f75734c48abai1WXcdghIJEvpu8bTpwhF+EUpBXkv9WSAAAAAAAAAABnT4cYSKtlckFFNFHnFoScYxneb0WaeH2NIPt5SyUJlg==",
]
this_role_name = [
  "gene-test-role",
]
this_security_group_ids = [
  toset([
    "sg-0jld8komf3dlzv23ytn1",
  ]),
]
this_vswitch_id = [
  "vsw-0jlwjdkk5rfu8l6ietewv",
]
```
