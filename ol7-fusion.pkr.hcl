#----------------------------------------------------------------------------------
# Packer template to build an Oracle Linux R7 image on VMware Fusion
# juliusn - Sun Dec  5 08:48:39 EST 2021
#----------------------------------------------------------------------------------

source "vmware-iso" "oraclelinux" {

  # VM settings
  vm_name              = var.vm_name
  display_name         = var.vm_name
  guest_os_type        = "oraclelinux7-64"
  shutdown_command     = "shutdown -h now"
  iso_url              = var.vm_iso_url
  iso_checksum         = var.vm_iso_checksum

  ssh_username         = var.vm_access_username
  ssh_password         = var.vm_access_password
  ssh_timeout          = var.vm_ssh_timeout
  
  cpus                 = var.cpu_count
  memory               = var.ram_gb * 1024
  cdrom_adapter_type   = "sata"
  disk_size            = var.vm_disk_size
  disk_adapter_type    = "pvscsi"
  vmdk_name            = "${var.vm_name}_disk"
  usb                  = "true"
  network_adapter_type = "vmxnet3"
  
  # Fusion settings
  disk_type_id         = "0"
  fusion_app_path      = "${var.fusion_app_directory}"
  output_directory     = "${var.fusion_output_directory}"
  version              = "18"

  vmx_data = {
    "ethernet0.present"     = "TRUE"
    "ethernet0.virtualdev"  = "vmxnet3"
    "scsi0.virtualdev"      = "pvscsi"
    "annotation"            = "${var.vm_name}"
    "vhv.enable"            = "TRUE"
    "nestedHVEnabled"       = "TRUE"
  }

  boot_wait              = var.boot_wait_iso
  boot_key_interval      = var.boot_key_interval_iso
  boot_keygroup_interval = var.boot_keygroup_interval_iso

  http_directory       = "http_directory/oracle-linux"

  boot_command = [
    "<wait><esc><wait> linux ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ol7-kickstart.cfg<enter><wait>"
  ]
}

build {

  sources = [
    "sources.vmware-iso.oraclelinux"
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
