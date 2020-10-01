#	Terraform Script For Single Instance


provider "azurerm" {

subscription_id = "ab5ab10c-174d-45de-829b-876aaaf4eaa7"
client_id = "af2033a7-f7e2-4034-9014-14d6666e6dd6"
client_secret =  "pejVsHGFRfgFugn804CPeLcrpMF27Bzw98kCswc2ir8="
tenant_id = "9afab3d3-0ec5-48eb-9315-22ee18221dc4"

}

resource "azurerm_resource_group" "singleInstance" {
    name = "${var.ResourceGroup_name_SingleInstance}"
    location = "${var.location}"
}
resource "azurerm_virtual_network" "singleInstance" {
    name = "${var.virtual_network_name_SingleInstance}"
    address_space = "${var.address_space}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"
}
resource "azurerm_subnet" "singleInstance" {
    name = "${var.subnet_name_SingleInstance}"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"
    virtual_network_name = "${azurerm_virtual_network.singleInstance.name}"
    address_prefix = "${var.address_prefix}"
}
resource "azurerm_public_ip" "singleInstance" {
    name = "${var.publicip_SingleInstance}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}

resource "azurerm_network_interface" "singleInstance" {
    name = "${var.network_interface_SingleInstance}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"

    ip_configuration {
        name = "${var.ipconfiguration_SingleInstance}"
        subnet_id = "${azurerm_subnet.singleInstance.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
public_ip_address_id = "${azurerm_public_ip.singleInstance.id}"
 }
}
resource "azurerm_storage_account" "singleInstance" {
    name = "${var.Storage_account_SingleInstance}"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "singleInstance" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"
    storage_account_name = "${azurerm_storage_account.singleInstance.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "singleInstance" {
    name = "${var.VM_name_SingleInstance}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.singleInstance.name}"
 network_interface_ids = ["${azurerm_network_interface.singleInstance.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "${var.Storage_OS_disk_name_SingleInstance}"
        vhd_uri = "${azurerm_storage_account.singleInstance.primary_blob_endpoint}${azurerm_storage_container.singleInstance.name}/singleInstance.vhd"
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
              host = "${azurerm_public_ip.singleInstance.ip_address}"
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
              host = "${azurerm_public_ip.singleInstance.ip_address}"

# key_file = "${file("/home/ec2-user/id_rsa")}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
        inline = [
                 "sudo sh /home/RRP/files/Jenkins_Script.sh",
                 "sudo sh /home/RRP/files/GitBucket_Script.sh",
                 "sudo sh /home/RRP/files/Tomcat_Script.sh",
                 "sudo sh /home/RRP/files/Sonarqube_Script.sh",
                 "sudo sh /home/RRP/files/AcceptenceTesting_Script.sh"
                 ]

}

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_resource_group" "rrpjenkinsslave1" {
    name = "rrpjenkinsslave1"
    location = "${var.location}"
}
resource "azurerm_virtual_network" "rrpjenkinsslave1" {
    name = "rrpjenkinsslave1"
    address_space = "${var.address_space}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
}
resource "azurerm_subnet" "rrpjenkinsslave1" {
    name = "rrpjenkinsslave1"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
    virtual_network_name = "${azurerm_virtual_network.rrpjenkinsslave1.name}"
    address_prefix = "${var.address_prefix}"
}
resource "azurerm_public_ip" "rrpjenkinsslave1" {
    name = "jenkinsslave1rrp"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
    
resource "azurerm_network_interface" "rrpjenkinsslave1" { 
    name = "rrpjenkinsslave1"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
    
    ip_configuration {
        name = "rrpjenkinsslave1configuration"
        subnet_id = "${azurerm_subnet.rrpjenkinsslave1.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.rrpjenkinsslave1.id}"
 }
}
resource "azurerm_storage_account" "rrpjenkinsslave1" {
    name = "rrpjenkinsslave1"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "rrpjenkinsslave1" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
    storage_account_name = "${azurerm_storage_account.rrpjenkinsslave1.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "rrpjenkinsslave1" {
    name = "rrpjenkinsslave1"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave1.name}"
 network_interface_ids = ["${azurerm_network_interface.rrpjenkinsslave1.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "rrpjenkinsslave1"
        vhd_uri = "${azurerm_storage_account.rrpjenkinsslave1.primary_blob_endpoint}${azurerm_storage_container.rrpjenkinsslave1.name}/rrpjenkinsslave1.vhd"
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
              host = "${azurerm_public_ip.rrpjenkinsslave1.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/JenkinsSlave_Script.sh"
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.rrpjenkinsslave1.ip_address}"
#             key_file = "${file("/home/ec2-user/id_rsa")}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}

resource "azurerm_resource_group" "rrpjenkinsslave2" {
    name = "rrpjenkinsslave2"
    location = "${var.location}"
}
resource "azurerm_virtual_network" "rrpjenkinsslave2" {
    name = "rrpjenkinsslave2"
    address_space = "${var.address_space}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
}
resource "azurerm_subnet" "rrpjenkinsslave2" {
    name = "rrpjenkinsslave2"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
    virtual_network_name = "${azurerm_virtual_network.rrpjenkinsslave2.name}"
    address_prefix = "${var.address_prefix}"
}
resource "azurerm_public_ip" "rrpjenkinsslave2" {
    name = "jenkinsslave2rrp"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
    
resource "azurerm_network_interface" "rrpjenkinsslave2" { 
    name = "rrpjenkinsslave2"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
    
    ip_configuration {
        name = "rrpjenkinsslave2configuration"
        subnet_id = "${azurerm_subnet.rrpjenkinsslave2.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.rrpjenkinsslave2.id}"
 }
}
resource "azurerm_storage_account" "rrpjenkinsslave2" {
    name = "rrpjenkinsslave2"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "rrpjenkinsslave2" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
    storage_account_name = "${azurerm_storage_account.rrpjenkinsslave2.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "rrpjenkinsslave2" {
    name = "rrpjenkinsslave2"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave2.name}"
 network_interface_ids = ["${azurerm_network_interface.rrpjenkinsslave2.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "rrpjenkinsslave2"
        vhd_uri = "${azurerm_storage_account.rrpjenkinsslave2.primary_blob_endpoint}${azurerm_storage_container.rrpjenkinsslave2.name}/rrpjenkinsslave2.vhd"
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
              host = "${azurerm_public_ip.rrpjenkinsslave2.ip_address}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }

  }

    provisioner "remote-exec" {
        inline = [
                 "sudo sh /home/RRP/files/JenkinsSlave_Script.sh"
                 ]

        connection {
              type = "${var.type}"
              user = "${var.admin_username}"
              password = "${var.admin_password}"
              host = "${azurerm_public_ip.rrpjenkinsslave2.ip_address}"
#             key_file = "${file("/home/ec2-user/id_rsa")}"
              private_key = "${file("/home/ec2-user/id_rsa")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}

