variable "region" {
  description = "the region used to launch this module resources."
  default = "cn-wulanchabu"
}
variable "access_key" {
  description = "the account access key"
}
variable "secret_key" {
  description = "the secret key of above acess key"
}
variable "instance_root_pwd" {
  description = "plain text of instance root password. before ciphered"
}
variable "name" {
  description = "naming prefix for any resources in gene test cluster"
  default = "gene-test"
}
variable "ssh_public_key_path" {
  description = "the login ssh pub_key for ecs instance"
  default = "D:\\cygwin64\\home\\Gene\\.ssh\\id_ed25519.pub"
}
variable "ecs_dry_run" {
  description = "dry run of the ecs instance creation"
  default = "true"
}
