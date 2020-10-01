#	Terraform Script For Multiple Instances

provider "azurerm" {

subscription_id = "ab5ab10c-174d-45de-829b-876aaaf4eaa7"
client_id = "af2033a7-f7e2-4034-9014-14d6666e6dd6"
client_secret =  "pejVsHGFRfgFugn804CPeLcrpMF27Bzw98kCswc2ir8="
tenant_id = "9afab3d3-0ec5-48eb-9315-22ee18221dc4"

}

resource "azurerm_resource_group" "multiresource" {
    name = "multipleresource"
    location = "${var.location}"
}
resource "azurerm_virtual_network" "multinetwork" {
    name = "multiplenetwork"
    address_space = "${var.address_space}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
}
resource "azurerm_subnet" "multisubnet" {
    name = "multiplesubnet"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    virtual_network_name = "${azurerm_virtual_network.multinetwork.name}"
    address_prefix = "${var.address_prefix}"
}
resource "azurerm_availability_set" "avset" {
  name                = "Set"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.multiresource.name}"

  tags {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "loadbalancerip" {
  name                         = "PublicIPForLB"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.multiresource.name}"
  public_ip_address_allocation = "static"
}
resource "azurerm_lb" "loadbalancer" {
  name                = "rrp-lb"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.multiresource.name}"

  frontend_ip_configuration {
    name                 = "rrplb-ip"
    public_ip_address_id = "${azurerm_public_ip.loadbalancerip.id}"
  }
}
resource "azurerm_lb_backend_address_pool" "rrpbackend-ip" {
  resource_group_name = "${azurerm_resource_group.multiresource.name}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer.id}"
  name                = "BackEndAddressPool"
  location            = "${var.location}"
}
resource "azurerm_lb_rule" "rrplb-rule" {
  resource_group_name            = "${azurerm_resource_group.multiresource.name}"
  loadbalancer_id                = "${azurerm_lb.loadbalancer.id}"
  name                           = "LBRule"
  location            = "${var.location}"
  protocol                       = "tcp"
  frontend_port                  = 8088
  backend_port                   = 8088
  frontend_ip_configuration_name = "rrplb-ip"
  probe_id                       = "${azurerm_lb_probe.rrplb-probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"
}
resource "azurerm_lb_probe" "rrplb-probe" {
  resource_group_name = "${azurerm_resource_group.multiresource.name}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer.id}"
  name                = "rrpProbe"
  location            = "${var.location}"
  port                = 8088
}

resource "azurerm_public_ip" "multirrp1" {
    name = "multiplerrp1ip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "multirrp1" {
    name = "multiplerrp1"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "multiplerrp1"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.multirrp1.id}"
    	load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"]
 }
}
resource "azurerm_storage_account" "multirrp1" {
    name = "multiplerrp1"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
  environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "multirrp1" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.multirrp1.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "multirrp1" {
    name = "multiplerrp1"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.multirrp1.id}"]
    vm_size = "${var.vm_size}"
    availability_set_id     = "${azurerm_availability_set.avset.id}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "multiplerrp1"
        vhd_uri = "${azurerm_storage_account.multirrp1.primary_blob_endpoint}${azurerm_storage_container.multirrp1.name}/MultiRRP.vhd"
        caching = "${var.caching}"
        create_option = "${var.create_option}"
    }

os_profile {
        computer_name = "${var.computer_name}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }
    os_profile_linux_config {
        disable_password_authentication = false
                ssh_keys {
      path =  "/home/RRP/.ssh/authorized_keys"
      key_data = "${file("/home/ec2-user/id_rsa.pub")}"

 }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.multirrp1.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.multirrp1.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }        
	inline = [

    "sudo sh /home/RRP/files/Jenkins_Script.sh",
    "sudo sh /home/RRP/files/GitBucket_Script.sh",
    "sudo sh /home/RRP/files/Tomcat_Script.sh",
                 ]
}
	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_public_ip" "multirrp2" {
    name = "multiplerrp2ip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "multirrp2" {
    name = "multiplerrp2"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "multiplerrp2"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.multirrp2.id}"
    	load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"]
 }
}
resource "azurerm_storage_account" "multirrp2" {
    name = "multiplerrp2"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
  environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "multirrp2" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.multirrp2.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "multirrp2" {
    name = "multiplerrp2"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.multirrp2.id}"]
    vm_size = "${var.vm_size}"
    availability_set_id     = "${azurerm_availability_set.avset.id}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "multiplerrp2"
        vhd_uri = "${azurerm_storage_account.multirrp2.primary_blob_endpoint}${azurerm_storage_container.multirrp2.name}/MultiRRP.vhd"
        caching = "${var.caching}"
        create_option = "${var.create_option}"
    }

os_profile {
        computer_name = "${var.computer_name}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }
    os_profile_linux_config {
        disable_password_authentication = false
                ssh_keys {
      path =  "/home/RRP/.ssh/authorized_keys"
      key_data = "${file("/home/ec2-user/id_rsa.pub")}"

 }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.multirrp2.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.multirrp2.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }        
	inline = [

    "sudo sh /home/RRP/files/Sonarqube_Script.sh",
    "sudo sh /home/RRP/files/Tomcat_Script.sh",
    "sudo sh /home/RRP/files/AcceptenceTesting_Script.sh",
                 ]
}
	tags {
		environment = "${var.environment}"
	}
}
resource "azurerm_public_ip" "Tomcat1RRP" {
    name = "TomcatVM1Publicip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "Tomcat1RRP" {
    name = "TomcatVM1NI"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "TomcatVM1ipconfiguration"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.Tomcat1RRP.id}"
	load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"]
 }
}
resource "azurerm_storage_account" "Tomcat1RRP" {
    name = "tomcatvm1storageacc"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }

}
resource "azurerm_storage_container" "Tomcat1RRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.Tomcat1RRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "Tomcat1RRP" {
    name = "TomcatVM1RRP"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.Tomcat1RRP.id}"]
    vm_size = "${var.vm_size}"
    availability_set_id     = "${azurerm_availability_set.avset.id}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "TomcatVM1OSdisk"
        vhd_uri = "${azurerm_storage_account.Tomcat1RRP.primary_blob_endpoint}${azurerm_storage_container.Tomcat1RRP.name}/Tomcat1RRP.vhd"
        caching = "${var.caching}"
        create_option = "${var.create_option}"
    }

os_profile {
        computer_name = "${var.computer_name}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }
    os_profile_linux_config {
        disable_password_authentication = false
                ssh_keys {
      path =  "/home/RRP/.ssh/authorized_keys"
      key_data = "${file("/home/ec2-user/id_rsa.pub")}"

    }
    }
provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.Tomcat1RRP.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/Tomcat_Script.sh",
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.Tomcat1RRP.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_public_ip" "Tomcat2RRP" {
    name = "TomcatVM2Publicip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "Tomcat2RRP" {
    name = "TomcatVM2NI"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "TomcatVM2ipconfiguration"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.Tomcat2RRP.id}"
	load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.rrpbackend-ip.id}"]
 }
}
resource "azurerm_storage_account" "Tomcat2RRP" {
    name = "tomcatvm2storageacc"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }

}
resource "azurerm_storage_container" "Tomcat2RRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.Tomcat2RRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "Tomcat2RRP" {
    name = "TomcatVM2RRP"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.Tomcat2RRP.id}"]
    vm_size = "${var.vm_size}"
    availability_set_id     = "${azurerm_availability_set.avset.id}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "TomcatVM2OSdisk"
        vhd_uri = "${azurerm_storage_account.Tomcat2RRP.primary_blob_endpoint}${azurerm_storage_container.Tomcat2RRP.name}/Tomcat2RRP.vhd"
        caching = "${var.caching}"
        create_option = "${var.create_option}"
    }

os_profile {
        computer_name = "${var.computer_name}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }
    os_profile_linux_config {
        disable_password_authentication = false
                ssh_keys {
      path =  "/home/RRP/.ssh/authorized_keys"
      key_data = "${file("/home/ec2-user/id_rsa.pub")}"

    }
    }
provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.Tomcat2RRP.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/Tomcat_Script.sh",
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.Tomcat2RRP.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
