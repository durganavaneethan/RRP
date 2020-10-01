STARTAWS
provider "aws" {
  access_key = "AWSaccessKey"
  secret_key = "AWSsecretKey"
  region     = "${var.region}"
}

resource "aws_security_group" "testus-east" {
  name        = "testus-east"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "testus-east"
  }
}

resource "aws_instance" "singleInstance" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags{
  Name="SingleInstance-RRP"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

connection {
  user = "${var.user}"
  private_key = "${file("AWSprivateKeyPath")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}

provisioner "remote-exec" {
  inline = ["sudo sh /home/ec2-user/files/Jenkins_Script.sh",
            "sudo sh /home/ec2-user/files/GitBucket_Script.sh",
	    "sudo sh /home/ec2-user/files/Tomcat_Script.sh",
	    "sudo sh /home/ec2-user/files/Sonarqube_Script.sh",
            "sudo sh /home/ec2-user/files/AcceptenceTesting_Script.sh"]
}
}
ENDAWS
