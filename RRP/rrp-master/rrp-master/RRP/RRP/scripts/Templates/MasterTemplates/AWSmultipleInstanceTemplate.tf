STARTAWS
  provider "aws" {
  access_key = "AWSaccessKey"
  secret_key = "AWSsecretKey"
  region     = "us-east-1"
}
resource "aws_security_group" "AWSsecurityGroup" {
  name        = "AWSsecurityGroup"
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
    Name = "AWSsecurityGroup"
  }
}

ENDAWS


STARTJENKINS
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.jenkins.id}"
  allocation_id = "eipalloc-33b06000"
}
resource "aws_instance" "jenkins" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags{
  Name="Jenkins-RRP"
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
  inline = ["sudo sh /home/ec2-user/files/Jenkins_Script.sh"]

}
}
ENDJENKINS

STARTGITBUCKET
resource "aws_instance" "gitbucket" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags {
  Name = "GitBucket-RRP"
}


connection {
  user = "${var.user}"
  private_key = "${file("AWSprivateKeyPath")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}

provisioner "remote-exec" {
  inline = ["sudo sh /home/ec2-user/files/GitBucket_Script.sh"]

}
}
ENDGITBUCKET

STARTDOCKER
resource "aws_instance" "tomcat" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags{
  Name="Tomcat-RRP"
  }

connection {
  user = "${var.user}"
  private_key = "${file("AWSprivateKeyPath")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}

provisioner "remote-exec" {

   inline=["sudo sh /home/ec2-user/files/Docker_Script.sh"]
}
}
ENDDOCKER

STARTTOMCAT
resource "aws_instance" "tomcat" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags{
  Name="Tomcat-RRP"
  }

connection {
  user = "${var.user}"
  private_key = "${file("AWSprivateKeyPath")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}

provisioner "remote-exec" {

   inline=["sudo sh /home/ec2-user/files/Tomcat_Script.sh"]
}
}
ENDTOMCAT

STARTSONARQUBE
resource "aws_instance" "sonarqube" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags {
    Name = "Sonarqube-RRP"
  }
connection {
  user = "${var.user}"
  private_key = "${file("AWSprivateKeyPath")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}

provisioner "remote-exec" {

   inline=["sudo sh /home/ec2-user/files/Sonarqube_Script.sh"]
}
}
ENDSONARQUBE

STARTSELENIUM
resource "aws_instance" "attd" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags {
    Name = "Selenium-RRP"
  }
connection {
  user = "${var.user}"
  private_key = "${file("AWSprivateKeyPath")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}

provisioner "remote-exec" {

   inline=["sudo sh /home/ec2-user/files/AcceptenceTesting_Script.sh"]
}
}

ENDSELENIUM

STARTMULTIRRP
resource "aws_instance" "multirrp" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags{
  Name="MultiRRP"
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
		inline = [

ENDMULTIRRP

STARTEIP_JENKINS
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.multirrp.id}"
  allocation_id = "eipalloc-33b06000"
}
ENDEIP_JENKINS

STARTEBS
ebs_block_device {
        device_name = "/dev/sdb"
        volume_size = 8
        volume_type = "gp2"
        delete_on_termination = "true"
  }

 connection {
            user = "ec2-user"
            private_key = "${file("AWSprivateKeyPath")}"
            timeout = "10m"
            port=443
            agent = false # true/false
  }
ENDEBS

STARTTARGET
resource "aws_alb_target_group" "RRPtarget" {
  name     = "RRP-target-group"
  port     = 8088
  protocol = "HTTP"
  vpc_id   = "vpc-8790a6e3"
}
ENDTARGET
STARTLOAD
resource "aws_alb" "RRPload" {
  name            = "rrp-loadbalancer"
  internal	  = false
  subnets         = ["subnet-11f56b67","subnet-3bf35c11","subnet-c33d45a6","subnet-5d378105","subnet-9f9deca2"]
  security_groups = ["${aws_security_group.AWSsecurityGroup.id}"]
}

resource "aws_alb_listener" "RRP-front_end" {
  load_balancer_arn = "${aws_alb.RRPload.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
ENDLOAD
    target_group_arn = "${aws_alb_target_group.RRPtarget.id}"
    type             = "forward"
  }
}


STARTMULTIGITBUCKETPROVISION
    "sudo sh /home/ec2-user/files/GitBucket_Script.sh",
ENDMULTIGITBUCKETPROVISION

STARTMULTISONARQUBEPROVISION
    "sudo sh /home/ec2-user/files/Sonarqube_Script.sh",
ENDMULTISONARQUBEPROVISION

STARTMULTITOMCATPROVISION
    "sudo sh /home/ec2-user/files/Tomcat_Script.sh",          
ENDMULTITOMCATPROVISION

STARTMULTIDOCKERPROVISION
    "sudo sh /home/ec2-user/files/Docker_Script.sh",          
ENDMULTIDOCKERPROVISION

STARTMULTIJENKINSPROVISION
	"sudo sh /home/ec2-user/files/Jenkins_Script.sh",
ENDMULTIJENKINSPROVISION

STARTMULTISELENIUMPROVISION
        "sudo sh /home/ec2-user/files/AcceptenceTesting_Script.sh",
ENDMULTISELENIUMPROVISION
