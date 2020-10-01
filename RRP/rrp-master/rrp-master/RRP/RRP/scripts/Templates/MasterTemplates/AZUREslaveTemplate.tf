resource "azurerm_resource_group" "rrpjenkinsslave" {
    name = "rrpjenkinsslave"
    location = "${var.location}"
}
resource "azurerm_virtual_network" "rrpjenkinsslave" {
    name = "rrpjenkinsslave"
    address_space = "${var.address_space}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
}
resource "azurerm_subnet" "rrpjenkinsslave" {
    name = "rrpjenkinsslave"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
    virtual_network_name = "${azurerm_virtual_network.rrpjenkinsslave.name}"
    address_prefix = "${var.address_prefix}"
}
resource "azurerm_public_ip" "rrpjenkinsslave" {
    name = "jenkinsslaverrp"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
}
    
resource "azurerm_network_interface" "rrpjenkinsslave" { 
    name = "rrpjenkinsslave"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
    
    ip_configuration {
        name = "rrpjenkinsslaveconfiguration"
        subnet_id = "${azurerm_subnet.rrpjenkinsslave.id}"
        private_ip_address_allocation = "${var.private_ip_address_allocation}"
        public_ip_address_id = "${azurerm_public_ip.rrpjenkinsslave.id}"
 }
}
resource "azurerm_storage_account" "rrpjenkinsslave" {
    name = "rrpjenkinsslave"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
    location = "${var.location}"
    account_type = "${var.account_type}"

    tags {
        environment = "${var.environment}"
    }
}
resource "azurerm_storage_container" "rrpjenkinsslave" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
    storage_account_name = "${azurerm_storage_account.rrpjenkinsslave.name}"
    container_access_type = "${var.container_access_type}"
}
resource "azurerm_virtual_machine" "rrpjenkinsslave" {
    name = "rrpjenkinsslave"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rrpjenkinsslave.name}"
 network_interface_ids = ["${azurerm_network_interface.rrpjenkinsslave.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "${var.publisher}"
        offer = "${var.offer}"
        sku = "${var.sku}"
        version = "${var.version}"
}

    storage_os_disk {
        name = "rrpjenkinsslave"
        vhd_uri = "${azurerm_storage_account.rrpjenkinsslave.primary_blob_endpoint}${azurerm_storage_container.rrpjenkinsslave.name}/rrpjenkinsslave.vhd"
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
              host = "${azurerm_public_ip.rrpjenkinsslave.ip_address}"
              private_key = "${file("AZUREprivateKey")}"
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
              host = "${azurerm_public_ip.rrpjenkinsslave.ip_address}"
#             key_file = "${file("AZUREprivateKey")}"
              private_key = "${file("AZUREprivateKey")}"
              port = "${var.port}"
              agent = "${var.agent}"
 }
}

    tags {
        environment = "${var.environment}"
    }
}

