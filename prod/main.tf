terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.6"
    }
  }
}

provider "libvirt" {
  alias = "vmhost01"
  uri   = "qemu+ssh://jenkins_automation@vmhost01/system?keyfile=../id_ed25519_jenkins"
  # uri   = "qemu+ssh://vmhost01/system"
}

provider "libvirt" {
  alias = "vmhost02"
  uri   = "qemu+ssh://jenkins_automation@vmhost02/system?keyfile=../id_ed25519_jenkins"
  # uri   = "qemu+ssh://vmhost02/system"
}

provider "libvirt" {
  alias = "vmhost03"
  uri   = "qemu+ssh://jenkins_automation@vmhost03/system?keyfile=../id_ed25519_jenkins"
  # uri   = "qemu+ssh://vmhost03/system"
}

variable "env" {
  type = string
}

resource "libvirt_volume" "jira" {
  provider         = libvirt.vmhost03
  name             = "jira-${var.env}.qcow2"
  pool             = var.env
  base_volume_name = "jira-base.qcow2"
  format           = "qcow2"
  base_volume_pool = var.env
}

resource "libvirt_domain" "jira" {
  provider  = libvirt.vmhost03
  name      = "jira-${var.env}"
  memory    = "8192"
  vcpu      = 4
  autostart = true

  // The MAC here is given an IP through mikrotik
  network_interface {
    macvtap  = "enp1s0"
    mac      = "52:54:00:EA:18:66"
    hostname = "jira-${var.env}"
  }

  network_interface {
    // network_id = libvirt_network.default.id
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.jira.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = 0
  }

}
