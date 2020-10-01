#	Terraform Script For Multiple Instances

  provider "aws" {
  access_key = "AKIAJGS7LXWA6BHYVWIQ"
  secret_key = "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"
  region     = "us-east-1"
}
resource "aws_security_group" "RRP-security" {
  name        = "RRP-security"
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
    Name = "RRP-security"
  }
}

resource "aws_instance" "multirrp_1" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["RRP-security"]
  key_name = "NEWRRP"

tags{
  Name="multirrp-1"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

connection {
  user = "${var.user}"
  private_key = "${file("/home/ec2-user/newrrp.pem")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}
	
	provisioner "remote-exec" {
		inline = [

    "sudo sh /home/ec2-user/files/GitBucket_Script.sh",
	"sudo sh /home/ec2-user/files/Jenkins_Script.sh",
      "sleep 10"
    ] 
   }
} 
resource "aws_instance" "multirrp_2" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["RRP-security"]
  key_name = "NEWRRP"

tags{
  Name="multirrp-2"
}

ebs_block_device {
  device_name = "${var.device_name}"
  volume_size = "${var.volume_size}"
  volume_type = "${var.volume_type}"
  delete_on_termination = "${var.delete_on_termination}"
}

connection {
  user = "${var.user}"
  private_key = "${file("/home/ec2-user/newrrp.pem")}"
  port = "${var.port}"
  agent = "${var.agent}"
}

provisioner "file" {
  source = "${var.source}"
  destination = "${var.destination}"
}
	
	provisioner "remote-exec" {
		inline = [

    "sudo sh /home/ec2-user/files/Sonarqube_Script.sh",
        "sudo sh /home/ec2-user/files/AcceptenceTesting_Script.sh",
      "sleep 10"
    ] 
   }
} 
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.multirrp_1.id}"
  allocation_id = "eipalloc-33b06000"
}
resource "aws_instance" "DevAppDeploy1" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["RRP-security"]
  key_name = "NEWRRP"

tags{
  Name="DevAppDeploy1-RRP"
  }

connection {
  user = "${var.user}"
  private_key = "${file("/home/ec2-user/newrrp.pem")}"
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
resource "aws_instance" "DevAppDeploy2" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["RRP-security"]
  key_name = "NEWRRP"

tags{
  Name="DevAppDeploy2-RRP"
  }

connection {
  user = "${var.user}"
  private_key = "${file("/home/ec2-user/newrrp.pem")}"
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
resource "aws_alb_target_group" "RRPDevTarget" {
  name     = "RRP-Dev-target-group"
  port     = 8088
  protocol = "HTTP"
  vpc_id   = "vpc-8790a6e3"
}
resource "aws_alb" "RRPDevLoad" {
  name            = "rrp-dev-loadbalancer"
  internal	  = false
  subnets         = ["subnet-11f56b67","subnet-3bf35c11","subnet-c33d45a6","subnet-5d378105","subnet-9f9deca2"]
  security_groups = ["${aws_security_group.RRP-security.id}"]
}

resource "aws_alb_listener" "RRPDev-front_end" {
  load_balancer_arn = "${aws_alb.RRPDevLoad.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.RRPDevTarget.id}"
    type             = "forward"
  }
}
resource "aws_alb_target_group_attachment" "DevAppDeploy1" {
  target_group_arn = "${aws_alb_target_group.RRPDevTarget.arn}"
  port             = 8088
  target_id        = "${aws_instance.DevAppDeploy1.id}"
}
resource "aws_alb_target_group_attachment" "DevAppDeploy2" {
  target_group_arn = "${aws_alb_target_group.RRPDevTarget.arn}"
  port             = 8088
  target_id        = "${aws_instance.DevAppDeploy2.id}"
}
