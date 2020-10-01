STARTAZURE
provider "azurerm" {

subscription_id = "AZUREsubscriptionID"
client_id = "AZUREclientID"
client_secret =  "AZUREsecretID"
tenant_id = "AZUREtenantID"

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
ENDAZURE

STARTLOAD
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

ENDLOAD

STARTJENKINS
resource "azurerm_public_ip" "JenkinsRRP" { 
    name = "${var.publicip_jenkinsVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}   
resource "azurerm_network_interface" "JenkinsRRP" {
    name = "${var.network_interface_jenkinsVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "${var.ipconfiguration_jenkinsVM}"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.JenkinsRRP.id}"
 }
}
resource "azurerm_storage_account" "JenkinsRRP" {
    name = "${var.Storage_account_jenkinsVM}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "JenkinsRRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.JenkinsRRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "JenkinsRRP" {
    name = "${var.VM_name_jenkinsVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.JenkinsRRP.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "${var.Storage_OS_disk_name_jenkinsVM}"
        vhd_uri = "${azurerm_storage_account.JenkinsRRP.primary_blob_endpoint}${azurerm_storage_container.JenkinsRRP.name}/RRPJenkins1.vhd"
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
      key_data = "${file("AZUREpublicKey")}"

    }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.JenkinsRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/Jenkins_Script.sh",
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.JenkinsRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
ENDJENKINS

STARTTOMCAT
resource "azurerm_public_ip" "TomcatRRP" {
    name = "TomcatVMPublicip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "TomcatRRP" {
    name = "TomcatVMNI"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "TomcatVMipconfiguration"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.TomcatRRP.id}"
	#place for tomcat load
 }
}
resource "azurerm_storage_account" "TomcatRRP" {
    name = "tomcatvmstorageacc"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }

}
resource "azurerm_storage_container" "TomcatRRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.TomcatRRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "TomcatRRP" {
    name = "TomcatVMRRP"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.TomcatRRP.id}"]
    vm_size = "${var.vm_size}"
    #place for tomcat set

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "TomcatVMOSdisk"
        vhd_uri = "${azurerm_storage_account.TomcatRRP.primary_blob_endpoint}${azurerm_storage_container.TomcatRRP.name}/TomcatRRP.vhd"
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
      key_data = "${file("AZUREpublicKey")}"

    }
    }
provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.TomcatRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
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
              host = "${azurerm_public_ip.TomcatRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
ENDTOMCAT

STARTGITBUCKET
resource "azurerm_public_ip" "GitBucketRRP" {
    name = "${var.publicip_GitBucketVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "GitBucketRRP" {
    name = "${var.network_interface_GitBucketVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "${var.ipconfiguration_GitBucketVM}"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.GitBucketRRP.id}"
 }
}
resource "azurerm_storage_account" "GitBucketRRP" {
    name = "${var.Storage_account_GitBucketVM}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
  environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "GitBucketRRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.GitBucketRRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "GitBucketRRP" {
    name = "${var.VM_name_GitBucketVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.GitBucketRRP.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "${var.Storage_OS_disk_name_GitBucketVM}"
        vhd_uri = "${azurerm_storage_account.GitBucketRRP.primary_blob_endpoint}${azurerm_storage_container.GitBucketRRP.name}/GitBucketVM.vhd"
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
      key_data = "${file("AZUREpublicKey")}"

 }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.GitBucketRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/GitBucket_Script.sh",
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.GitBucketRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
ENDGITBUCKET

STARTSONARQUBE
resource "azurerm_public_ip" "SonarqubeRRP" {
    name = "${var.publicip_SonarqubeVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "SonarqubeRRP" {
    name = "${var.network_interface_SonarqubeVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "${var.ipconfiguration_SonarqubeVM}"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.SonarqubeRRP.id}"
 }
}
resource "azurerm_storage_account" "SonarqubeRRP" {
    name = "${var.Storage_account_SonarqubeVM}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
  environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "SonarqubeRRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.SonarqubeRRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "SonarqubeRRP" {
    name = "${var.VM_name_SonarqubeVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.SonarqubeRRP.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "${var.Storage_OS_disk_name_SonarqubeVM}"
        vhd_uri = "${azurerm_storage_account.SonarqubeRRP.primary_blob_endpoint}${azurerm_storage_container.SonarqubeRRP.name}/RRPSonarqube.vhd"
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
      key_data = "${file("AZUREpublicKey")}"

 }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.SonarqubeRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/Sonarqube_Script.sh",
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.SonarqubeRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
ENDSONARQUBE

STARTSELENIUM
resource "azurerm_public_ip" "attdRRP" {
    name = "${var.publicip_attdVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "attdRRP" {
    name = "${var.network_interface_attdVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "${var.ipconfiguration_attdVM}"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
  public_ip_address_id = "${azurerm_public_ip.attdRRP.id}"
 }
}
resource "azurerm_storage_account" "attdRRP" {
    name = "${var.Storage_account_attdVM}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "attdRRP" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.attdRRP.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "attdRRP" {
    name = "${var.VM_name_attdVM}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.attdRRP.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "${var.Storage_OS_disk_name_attdVM}"
        vhd_uri = "${azurerm_storage_account.attdRRP.primary_blob_endpoint}${azurerm_storage_container.attdRRP.name}/RRPattd.vhd"
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
      key_data = "${file("AZUREpublicKey")}"

    }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.attdRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/AcceptenceTesting_Script.sh",
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.attdRRP.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}
ENDSELENIUM

STARTMULTIRRP
resource "azurerm_public_ip" "multirrp" {
    name = "multiplerrpip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
resource "azurerm_network_interface" "multirrp" {
    name = "multiplerrp"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"

    ip_configuration {
        name = "multiplerrp"
        subnet_id = "${azurerm_subnet.multisubnet.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.multirrp.id}"
    	#place for tomcat load
 }
}
resource "azurerm_storage_account" "multirrp" {
    name = "multiplerrp"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
  environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "multirrp" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
    storage_account_name = "${azurerm_storage_account.multirrp.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "multirrp" {
    name = "multiplerrp"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.multiresource.name}"
 network_interface_ids = ["${azurerm_network_interface.multirrp.id}"]
    vm_size = "${var.vm_size}"
    #place for tomcat set

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "multiplerrp"
        vhd_uri = "${azurerm_storage_account.multirrp.primary_blob_endpoint}${azurerm_storage_container.multirrp.name}/MultiRRP.vhd"
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
      key_data = "${file("AZUREpublicKey")}"

 }
    }
 provisioner "file" {
      source = "${var.source}"
      destination = "${var.destination}"
 connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.multirrp.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.multirrp.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }        
	inline = [

ENDMULTIRRP

STARTMULTIGITBUCKETPROVISION
    "sudo sh /home/RRP/files/GitBucket_Script.sh",
ENDMULTIGITBUCKETPROVISION

STARTMULTISONARQUBEPROVISION
    "sudo sh /home/RRP/files/Sonarqube_Script.sh",
ENDMULTISONARQUBEPROVISION

STARTMULTITOMCATPROVISION
    "sudo sh /home/RRP/files/Tomcat_Script.sh",
ENDMULTITOMCATPROVISION

STARTMULTIJENKINSPROVISION
    "sudo sh /home/RRP/files/Jenkins_Script.sh",
ENDMULTIJENKINSPROVISION
STARTMULTISELENIUMPROVISION
    "sudo sh /home/RRP/files/AcceptenceTesting_Script.sh",
ENDMULTISELENIUMPROVISION

