#----------------------------------------------------------------------------------
# Packer template to build an Oracle Linux R7 image on VirtualBox
# juliusn - Sun Dec  5 08:48:39 EST 2021
#----------------------------------------------------------------------------------

source "virtualbox-iso" "oraclelinux" {

  # VM settings
  vm_name              = var.vm_name
  guest_os_type        = "Oracle_64"
  shutdown_command     = "shutdown -h now"
  iso_url              = var.vm_iso_url
  iso_checksum         = var.vm_iso_checksum

  ssh_username         = var.vm_access_username
  ssh_password         = var.vm_access_password
  ssh_timeout          = var.vm_ssh_timeout
  
  cpus                 = var.cpu_count
  memory               = var.ram_gb * 1024
  disk_size            = var.vm_disk_size
  usb                  = "true"
  
  ## Virtualbox settings
  output_directory         = "output_directory"
  hard_drive_nonrotational = "true"
  hard_drive_interface     = "sata"
  sata_port_count          = "5"
  guest_additions_path     = "iso/VBoxGuestAdditions_6.1.26.iso"

  vboxmanage = [
			["modifyvm", "{{.Name}}", "--memory", var.ram_gb * 1024],
			["modifyvm", "{{.Name}}", "--cpus", var.cpu_count],
      ["modifyvm", "{{.Name}}", "--vram", 128],
      ["modifyvm", "{{.Name}}", "--accelerate3d", "off"],
      ["modifyvm", "{{.Name}}", "--paravirtprovider", "kvm"],
      ["modifyvm", "{{.Name}}", "--firmware", "bios"],
      ["modifyvm", "{{.Name}}", "--nestedpaging", "on"],
      ["modifyvm", "{{.Name}}", "--apic", "on"],
      ["modifyvm", "{{.Name}}", "--pae", "on"]
	]
  
  boot_wait                 = var.boot_wait_iso
  boot_keygroup_interval    = var.boot_keygroup_interval_iso
  
  http_directory            = "http_directory/oracle-linux"

  boot_command = [
    "<wait><esc><wait> linux ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ol7-kickstart.cfg<enter><wait>"
  ]
}

build {

  sources = [
    "sources.virtualbox-iso.oraclelinux"
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
      "tce-scripts/10-update-certificates.sh",
      "tce-scripts/11-oraclelinux-settings.sh",
      "tce-scripts/12-oraclelinux-docker.sh",
      "tce-scripts/14-install-hashicorp.sh",
      "tce-scripts/15-install-govc.sh",
      "tce-scripts/16-install-nmon.sh",
      "tce-scripts/17-install-password-store.sh",
      "tce-scripts/19-user-settings.sh",
      "tce-scripts/20-oraclelinux-cleanup.sh",
      "tce-scripts/21-install-ntp-client.sh",
      "tce-scripts/22-install-postfix.sh",
      # "tce-scripts/27-install-powershell.sh",
      "tce-scripts/31-download-k8s-tools.sh"
    ]
  }
  
  provisioner "file" {
    sources     = ["ova"]
    destination = "/home/tce/ova"
  }

  provisioner "file" {
    sources     = ["tce"]
    destination = "/home/tce/tce"
  }

  provisioner "shell" {
    inline = [
      "chown -R tce:tce /home/tce/ova",
      "chown -R tce:tce /home/tce/tce",
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
