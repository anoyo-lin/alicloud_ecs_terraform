provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}


#############################################
########### rbac  handling ##################
#############################################

# ram
resource "alicloud_ram_user" "user" {
  name         = "${var.name}-user"
  display_name = "${var.name}-user"
  comments     = "seismic-test"
  force        = true
}


resource "alicloud_ram_access_key" "ak" {
  user_name   = alicloud_ram_user.user.name
  secret_file = "${var.name}-access-key"
}

resource "alicloud_ram_group" "group" {
  name     = "${var.name}-group"
  comments = "ram user group."
  force    = true
}

resource "alicloud_ram_group_membership" "membership" {
  group_name = alicloud_ram_group.group.name
  user_names = [alicloud_ram_user.user.name]
}

# Create a new RAM Role.
resource "alicloud_ram_role" "role" {
  name     = "${var.name}-role"
  document = <<EOF
  {
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "apigateway.aliyuncs.com",
            "ecs.aliyuncs.com"
          ]
        }
      }
    ],
    "Version": "1"
  }
EOF
  description = "we can assume the admin of alicloud in ecs instance"
  force       = true
}

resource "alicloud_ram_policy" "policy" {
  policy_name = "${var.name}-admin-policy"
  policy_document = <<EOF
    {
        "Statement": [
            {
                "Action": "*",
                "Effect": "Allow",
                "Resource": "*"
            }
        ],
        "Version": "1"
    }
EOF
  description = "${var.name}-admin-policy"
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.policy.name
  policy_type = alicloud_ram_policy.policy.type
  role_name   = alicloud_ram_role.role.name
}
resource "alicloud_ram_group_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.policy.name
  policy_type = alicloud_ram_policy.policy.type
  group_name  = alicloud_ram_group.group.name
}
resource "alicloud_ram_user_policy_attachment" "attach" {
  policy_name = alicloud_ram_policy.policy.name
  policy_type = alicloud_ram_policy.policy.type
  user_name   = alicloud_ram_user.user.name
}

# note, we can assume the role in ecs instance

#############################################
########## sensitive info handling ##########
#############################################

// # create kms key to perform encryption on disk
// resource "alicloud_kms_key" "key" {
//   description            = "${var.name}-kms-key "
//   pending_window_in_days = "7"
//   status              = "Enabled"
// }
// resource "alicloud_kms_ciphertext" "encrypted" {
//   key_id = alicloud_kms_key.key.id
//   plaintext = var.instance_root_pwd
// }
// 
// data "alicloud_kms_plaintext" "plaintext" {
//   ciphertext_blob = alicloud_kms_ciphertext.encrypted.ciphertext_blob
// }


#############################################
##########  ecs instance creation ###########
#############################################

# ssh access key
resource "alicloud_key_pair" "publickey" {
    public_key = file(var.ssh_public_key_path)
}



# select the cloud region
data "alicloud_zones" "default" {
  available_instance_type = "ecs.t6-c1m2.large"
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
  multi = "false"
}

# Create New VPC
resource "alicloud_vpc" "vpc" {
  vpc_name       = "${var.name}-vpc"
  cidr_block = "172.16.0.0/16"
}

# Create New security group
resource "alicloud_security_group" "group" {
  name        = "${var.name}-sg"
  description = "${var.name}-security-group"
  vpc_id      = alicloud_vpc.vpc.id
  depends_on = [
    alicloud_vpc.vpc
  ]
}
# accept all tcp in sg-rule
resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
  depends_on = [
    alicloud_security_group.group
  ]
}
# create subnet for vpc
resource "alicloud_vswitch" "vswitch" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.1.0/24"
  zone_id = data.alicloud_zones.default.zones[0].id
  vswitch_name      = "${var.name}-vswitch"
  depends_on = [
    alicloud_vpc.vpc
  ]
}
// # create elb for subnet
// resource "alicloud_slb" "slb" {
//   name       = "${var.name}-slb"
//   vswitch_id = alicloud_vswitch.vswitch.id
//   depends_on = [
//     alicloud_vswitch.vswitch
//   ]
// }
// # create nat gatway
// resource "alicloud_nat_gateway" "default" {
//     vpc_id        = alicloud_vpc.vpc.id
//     specification = "Small"
//     name          = "${var.name}-natgw"
//     lifecycle {
//       prevent_destroy = true
//     }
//     depends_on = [
//       alicloud_vswitch.vswitch
//     ]
// 
// }
// # attach an eip to nat gateway
// resource "alicloud_eip" "eip" {
//     bandwidth = "10"
//     depends_on = [
//       alicloud_nat_gateway.default
//     ]
// }
// 
// resource "alicloud_eip_association" "eipassoc" {
//     allocation_id = alicloud_eip.eip[count.index].id
//     instance_id = alicloud_nat_gateway.default[count.index].id
//     depends_on = [
//       alicloud_eip.eip
//     ]
// 
// }
// # enable snat for internal subnet
// resource "alicloud_snat_entry" "default" {
//     snat_table_id = alicloud_nat_gateway.default.0.snat_table_id
//     source_vswitch_id = alicloud_vswitch.vswitch[count.index].id
//     snat_ip = alicloud_eip.eip.0.ip_address
// 
//     depends_on = [
//       alicloud_eip_association.eipassoc
//     ]
// 
// }

resource "alicloud_instance" "instance" {
  availability_zone = data.alicloud_zones.default.zones[0].id
  security_groups   = alicloud_security_group.group[*].id

  instance_type              = "ecs.t6-c1m2.large"
  system_disk_category       = "cloud_efficiency"
  system_disk_name           = "${var.name}-system-disk"
  system_disk_description    = "${var.name}-system-disk-description"
  image_id                   = "ubuntu_18_04_x64_20G_alibase_20210420.vhd"
  instance_name              = "${var.name}-instance"
  host_name                  = "${var.name}"
  vswitch_id                 = alicloud_vswitch.vswitch.id
  key_name                   = alicloud_key_pair.publickey.id
  role_name                  = alicloud_ram_role.role.name
  user_data                  = local.user_data
  dry_run                    = var.ecs_dry_run
#  password                   = data.alicloud_kms_plaintext.plaintext.plaintext
  internet_max_bandwidth_out = 5
//  data_disks {
//    name        = "disk2"
//    size        = 40
//    category    = "cloud_efficiency"
//    description = "disk2"
//    encrypted   = true
//    kms_key_id  = alicloud_kms_key.key.id
//  }
}
