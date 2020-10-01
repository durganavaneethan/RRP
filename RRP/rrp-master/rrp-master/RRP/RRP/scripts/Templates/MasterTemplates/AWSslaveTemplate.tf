resource "aws_instance" "jenkins-Slave" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups  = ["AWSsecurityGroup"]
  key_name = "AWSprivateKeyName"

tags{
  Name="jenkins-Slave"
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
	    "sudo sh /home/ec2-user/files/JenkinsSlave_Script.sh"
	    ]

}
}

