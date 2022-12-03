variable "AWS_REGION" {
  default = "us-east-2"
}

#and based on the region it will create the ami images so
variable "AMIS" {
  type = map(any)
  default = {
    ap-south-1 = "ami-062df10d14676e201" #take this id from the aws console.for ubuntu 20.04
  }
}

#and will define other variables to define ssh keys
variable "PRIV_KEY_PATH" {
  default = "terraformkey" #this will help to login to ubuntu
}

variable "PUB_KEY_PATH" {
  default = "terraformkey.pub"
}

variable "USERNAME" {
  default = "ubuntu"
}

variable "MYIP" {
  default = "0.0.0.0/0" #public ip of instance otherwise put 0.0.0.0/0
}

variable "rmquser" { #this is for amazon mq creation for rabbit mq
  default = "rabbit"
}

variable "rmqpass" {
  default = "terraforminstance@123" #make sure it is longer than 12 chars
}

variable "dbuser" {
  default = "admin"
}

#will need to create amazon RDS database server so create username and pass for login to RDS and provision with schema of the database username and pass
variable "dbname" {
  default = "accounts" #database name
}

variable "dbpass" {
  default = "admin123"
}

variable "instance_count" { #no.of instance count that you want to create
  default = "1"
}

variable "VPC_NAME" {
  default = "terraform-VPC"
}

#we are going to create 3 subnets for VPCs like in 3 zones we will create the copis
variable "Zone1" {
  default = "us-east-2a"
}

variable "Zone2" {
  default = "us-east-2b"
}
variable "Zone3" {
  default = "us-east-2c"
}

#using this CIDR we will create the subnets as below
variable "VpcCIDR" {
  default = "172.21.0.0/16"
}
variable "PubSub1CIDR" {
  default = "172.21.1.0/24"
}
variable "PubSub2CIDR" {
  default = "172.21.2.0/24"
}
variable "PubSub3CIDR" {
  default = "172.21.3.0/24"
}
variable "PriSub1CIDR" {
  default = "172.21.4.0/24"
}
variable "PriSub2CIDR" {
  default = "172.21.5.0/24"
}
variable "PriSub3CIDR" {
  default = "172.21.6.0/24"
}
#so total of 6 subnets in the vpc and it might take time
