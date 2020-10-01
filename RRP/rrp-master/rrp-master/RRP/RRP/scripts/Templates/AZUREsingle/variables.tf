
####################AZURE PROVIDER AUTHENTICATION DETAILS#########################


variable "subscription_id" {
description = "The Azure Subscription id"
default = "ab5ab10c-174d-45de-829b-876aaaf4eaa7"
}

variable "client_id" {
          default = "af2033a7-f7e2-4034-9014-14d6666e6dd6"
}

variable "client_secret"{
           default = "pejVsHGFRfgFugn804CPeLcrpMF27Bzw98kCswc2ir8="
}

variable "tenant_id"{
            default ="9afab3d3-0ec5-48eb-9315-22ee18221dc4"
}

##################### VARIABLES_FOR_SINGLE_INSTANCE#################################

variable "ResourceGroup_name_SingleInstance"{
             default = "Singleinstance"
}
variable "virtual_network_name_SingleInstance"{
             default = "SingleInstanceVirtualNetwork"
}
variable "subnet_name_SingleInstance"{
             default = "SingleInstanceSubnet"
}
variable "publicip_SingleInstance"{
             default = "SingleInstancePublicip"
}
variable "network_interface_SingleInstance"{
             default = "SingleInstanceNI"
}
variable "ipconfiguration_SingleInstance"{
             default = "SingleInstanceipconfiguration"
}
variable "Storage_account_SingleInstance"{
             default = "singleinstorage"
}
variable "VM_name_SingleInstance"{
             default = "SingleInstanceVM"
}
variable "Storage_OS_disk_name_SingleInstance"{
             default = "SingleInstanceOSdisk"
}

################### VARIABLES_FOR_JENKINS_INSTANCE #################################

variable "ResourceGroup_name_jenkinsVM"{
             default = "JenkinsVM"
}
variable "virtual_network_name_jenkinsVM"{
             default = "JenkinsVMVirtualNetwork"
}
variable "subnet_name_jenkinsVM"{
             default = "JenkinsVMSubnet"
}
variable "publicip_jenkinsVM"{
             default = "JenkinsVMPublicip"
}
variable "network_interface_jenkinsVM"{
             default = "JenkinsVMNI"
}
variable "ipconfiguration_jenkinsVM"{
             default = "JenkinsVMipconfiguration"
}
variable "Storage_account_jenkinsVM"{
             default = "jenkinsvmstorageacc"
}
variable "VM_name_jenkinsVM"{
             default = "JenkinsVM"
}
variable "Storage_OS_disk_name_jenkinsVM"{
             default = "JenkinsVMOSdisk"
}

####################### VARIABLES_FOR_TOMCAT_INSTANCE ###############################

variable "ResourceGroup_name_TomcatVM"{
             default ="TomcatVM"
}
variable "virtual_network_name_TomcatVM"{
             default = "TomcatVMVirtualNetwork"
}
variable "subnet_name_TomcatVM"{
             default = "TomcatVMSubnet"
}
variable "publicip_TomcatVM"{
             default = "TomcatVMPublicip"
}
variable "network_interface_TomcatVM"{
             default = "TomcatVMNI"
}
variable "ipconfiguration_TomcatVM"{
             default = "TomcatVMipconfiguration"
}
variable "Storage_account_TomcatVM"{
             default = "tomcatvmstorageacc"
}
variable "VM_name_TomcatVM"{
             default = "TomcatVM"
}
variable "Storage_OS_disk_name_TomcatVM"{
             default = "TomcatVMOSdisk"
}

####################### VARIABLES_FOR_GITBUCKET_INSTANCE ###############################


variable "ResourceGroup_name_GitBucketVM"{
             default ="GitBucketVM"
}
variable "virtual_network_name_GitBucketVM"{
             default = "GitBucketVMVirtualNetwork"
}
variable "subnet_name_GitBucketVM"{
             default = "GitBucketVMSubnet"
}
variable "publicip_GitBucketVM"{
             default = "GitBucketVMPublicip"
}
variable "network_interface_GitBucketVM"{
             default = "GitBucketVMNI"
}
variable "ipconfiguration_GitBucketVM"{
             default = "GitBucketVMipconfiguration"
}
variable "Storage_account_GitBucketVM"{
             default = "gitbucketvmstorageacc"
}
variable "VM_name_GitBucketVM"{
             default = "GitBucketVM"
}
variable "Storage_OS_disk_name_GitBucketVM"{
             default = "GitBucketVMOSdisk"
}

####################### VARIABLES_FOR_SONARQUBE_INSTANCE ###############################


variable "ResourceGroup_name_SonarqubeVM"{
             default ="SonarqubeVM"
}
variable "virtual_network_name_SonarqubeVM"{
             default = "SonarqubeVMVirtualNetwork"
}
variable "subnet_name_SonarqubeVM"{
             default = "SonarqubeVMSubnet"
}
variable "publicip_SonarqubeVM"{
             default = "SonarqubeVMPublicip"
}
variable "network_interface_SonarqubeVM"{
             default = "SonarqubeVMNI"
}
variable "ipconfiguration_SonarqubeVM"{
             default = "SonarqubeVMipconfiguration"
}
variable "Storage_account_SonarqubeVM"{
             default = "sonarqubevmstorageacc"
}
variable "VM_name_SonarqubeVM"{
             default = "SonarqubeVM"
}
variable "Storage_OS_disk_name_SonarqubeVM"{
             default = "SonarqubeVMOSdisk"
}
######################
variable "location"{
             default = "East US"
}
variable "address_space"{
            default = ["10.0.0.0/16"]
}
variable "address_prefix"{
             default = "10.0.2.0/24"
}
variable "public_ip_address_allocation"{
            default = "static"
}
variable "private_ip_address_allocation"{
            default = "dynamic"
}
variable "account_type"{
            default = "Standard_LRS"
}
variable "environment"{
            default = "staging"
}
variable "container_access_type" {
            default = "private"
}

########Virtual Machine Details#################

variable "vm_size"{
           default = "Standard_DS1_v2"
}

variable "publisher" {
          default = "Canonical"
}
variable "offer" {
          default = "UbuntuServer"
}
variable "sku" {
          default = "14.04.2-LTS"
}
variable "version" {
          default = "latest"
}
variable "caching" {
          default = "ReadWrite"
}
variable "create_option" {
          default = "FromImage"
}
variable "computer_name" {
          default = "hostname"
}
variable "admin_username" {
          default = "RRP"
}
variable "admin_password" {
          default = "Password1234!"
}
variable "key_data"{
          default = "/home/ec2-user/.ssh/id_rsa.pub"
}
variable "private_key"{
          default = "/home/ec2-user/id_rsa"
}
variable "type" {
          default = "ssh"

}
variable "port"{
         default = 22
}
variable "agent"{
          default = "false"
}
variable "source"{
         default = "../files"
}
variable "destination"{
          default = "/home/RRP/"
}

