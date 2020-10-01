#variable "access_key" {
#description = "The AWS access key."
#}

#variable "secret_key"{
#description = "The AWS secret key."
#}

#variable "private_key" {
#description = "The AWS private key path."
#}

variable "region"{
         default = "us-east-1"
}

variable "ami" {
          #default = "ami-9fd7ae88"
	  #default = "ami-b63769a1"
	   default = "ami-a4c7edb2"
}
variable "dockerami" {
         default = "ami-f2e7b2e5"
}

variable "instance_type" {
#          default = "t2.large"
          default = "t2.2xlarge"
}

variable "security_groups"{
           default = ["us-east"]
}

#variable "key_name"{
#         default = "NEWRRP"
#}

variable "device_name"{
           default = "/dev/sdb"
}

variable "volume_size"{
           default = 8
}

variable "volume_type"{
            default = "gp2"
}

variable "delete_on_termination"{
            default = "true"
}

 variable "port"{
          default = 22 
}

variable "user"{
          default = "ec2-user"
}

variable "agent"{
          default = false
}

variable "source"{
          default = "../files"
}

variable "destination"{
          default = "/home/ec2-user/"
}
