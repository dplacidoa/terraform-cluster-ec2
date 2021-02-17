variable "name_region" {
  type    = string
  default = "us-east-2"
}
variable "key_pair" {
  type    = string
  default = "david"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "ami_type" {
  type    = string
  default = "ami-03d64741867e7bb94" #Red Hat Enterprise Linux 8
}
variable "availability_zone_A" {
  type    = string
  default = "us-east-2a"
}
variable "availability_zone_B" {
  type    = string
  default = "us-east-2b"
}