#----------------------------------------------------------------------------------
# Packer template to build an Oracle Linux R7 image on VMware vCenter
# juliusn - Sun Dec  5 08:48:39 EST 2021
#----------------------------------------------------------------------------------

packer {
  required_version = ">= 1.7.0"
}

source "vsphere-iso" "oraclelinux" {

  # VM settings
  vm_name              = var.vm_name
  guest_os_type        = "oraclelinux7_64Guest"
  shutdown_command     = "shutdown -h now"
  vm_version           = var.vm_guest_version
  iso_url              = var.vm_iso_url
  iso_checksum         = var.vm_iso_checksum

  ssh_username         = var.vm_access_username
  ssh_password         = var.vm_access_password
  ssh_timeout          = var.vm_ssh_timeout
  
  CPUs                 = var.cpu_count
  CPU_hot_plug         = true
  RAM                  = var.ram_gb * 1024
  RAM_hot_plug         = true
  disk_controller_type = ["pvscsi"]

  network_adapters {
    network = var.vcenter_port_group
    network_card = "vmxnet3"
  }
  storage {
    disk_size = var.vm_disk_size
    disk_thin_provisioned = true
  }

  #  vCenter settings
  vcenter_server       = var.vcenter_hostname
  username             = var.vcenter_username
  password             = var.vcenter_password
  cluster              = var.vcenter_cluster
  datacenter           = var.vcenter_datacenter
  datastore            = var.vcenter_datastore
  folder               = var.vcenter_folder
  insecure_connection  = true
  convert_to_template  = true
  remove_cdrom         = true
  boot_order           = "disk,cdrom"

  http_directory       = "http_directory/oracle-linux"

  boot_command = [
    "<wait><esc><wait> linux ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ol7-kickstart.cfg<enter><wait>"
  ]
}

build {

  sources = [
    "sources.vsphere-iso.oraclelinux"
  ]
  
  provisioner "file" {
    sources     = ["tce-scripts"]
    destination = "/root/scripts"
  }

  provisioner "file" {
    sources     = ["certs"]
    destination = "/root/certs"
  }

  provisioner "shell" {
    scripts = [
      "scripts/10-update-certificates.sh",
      "scripts/11-oraclelinux-settings.sh",
      "scripts/12-oraclelinux-docker.sh",
      "scripts/14-install-hashicorp.sh",
      "scripts/15-install-govc.sh",
      "scripts/16-install-nmon.sh",
      "scripts/17-install-password-store.sh",
      "scripts/19-user-settings.sh",
      "scripts/20-oraclelinux-cleanup.sh",
      "scripts/21-install-ntp-client.sh",
      "scripts/22-install-postfix.sh",
      # "scripts/27-install-powershell.sh",
      "scripts/31-tce-download-tanzu.sh"
    ]
  }
  
  provisioner "file" {
    sources     = ["ova"]
    destination = "/home/tce/ova"
  }

  provisioner "shell" {
    inline = [
      "chown -R tce:tce /home/tce/ova",
      "su - tce -c /home/tce/scripts/33-tce-install.sh",
      "su - tce -c /home/tce/scripts/36-configure-password-store.sh"
    ]
  }

  post-processor "manifest" {
    output = "oraclelinux.manifest.json"
    strip_path = true
  }
}

variable "vm_name" {
  type    = string
}

variable "vm_guest_os_type" {
  type    = string
}

variable "vm_guest_version" {
  type    = string
}

variable "vm_access_username" {
  type    = string
}

variable "vm_access_password" {
  type    = string
}

variable "vm_ssh_timeout" {
  type    = string
}

variable "cpu_count" {
  type    = number
}

variable "ram_gb" {
  type    = number
}

variable "vm_disk_size" {
  type    = number
}

variable "boot_key_interval_iso" {
  type    = string
}

variable "boot_wait_iso" {
  type    = string
}

variable "boot_keygroup_interval_iso" {
  type    = string
}

variable "vm_iso_url" {
  type    = string
}

variable "vm_iso_checksum" {
  type    = string
}

variable "vcenter_hostname" {
  type    = string
}

variable "vcenter_username" {
  type    = string
}

variable "vcenter_password" {
  type    = string
}

variable "vcenter_cluster" {
  type    = string
}

variable "vcenter_datacenter" {
  type    = string
}

variable "vcenter_datastore" {
  type    = string
}

variable "vcenter_folder" {
  type    = string
}

variable "vcenter_port_group" {
  type    = string
}

variable "esx_remote_type" {
  type    = string
}

variable "esx_remote_hostname" {
  type    = string
}

variable "esx_remote_datastore" {
  type    = string
}

variable "esx_remote_username" {
  type    = string
}

variable "esx_remote_password" {
  type    = string
}

variable "esx_port_group" {
  type    = string
}

variable "fusion_app_directory" {
  type    = string
}
variable "fusion_output_directory" {
  type    = string
}
