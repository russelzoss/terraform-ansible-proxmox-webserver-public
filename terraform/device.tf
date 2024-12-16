locals {
  device_network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", {
      private_ip              = var.device_private_ip,
      private_subnet          = var.private_subnet,
      public_ip               = var.device_public_ip,
      gateway                 = var.gateway,
      nameservers             = var.nameservers
    })
  device_network_config_hash  = sha256(local.device_network_config)

  device_user_data = templatefile("${path.module}/cloud-init/user-data.tftpl", {
    hostname        = var.device_hostname,
    user            = var.user,
    ssh_keys        = var.ssh_keys,
    hashed_password = var.hashed_password
  })
  device_user_data_hash       = sha256(local.device_user_data)
}

resource "null_resource" "upload_cloud_init_device" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = local.proxmox_ip
  }
  
  triggers = {
    network_config_hash = local.device_network_config_hash
    user_data_hash      = local.device_user_data_hash
  }

  provisioner "file" {
    content     = local.device_network_config
    destination = "/var/lib/vz/snippets/${var.device_hostname}-network-config.yaml"
  
    }
  
  provisioner "file" {
    content     = local.device_user_data
    destination = "/var/lib/vz/snippets/${var.device_hostname}-user-data.yaml"
  }
}

resource "proxmox_vm_qemu" "device" {
  target_node = var.node_name
  clone       = var.vm_template
  name        = var.device_hostname
  cicustom    = "network=local:snippets/${var.device_hostname}-network-config.yaml,user=local:snippets/${var.device_hostname}-user-data.yaml"

  cores   = 1
  memory  = 1024
  sockets = 1
  scsihw  = "virtio-scsi-pci"
  os_type = "cloud-init"

  disk {
    type    = "disk"
    slot    = "scsi0"
    storage = var.storage_pool
    format  = "raw"
    size    = "10G"
  }

  disk {
    type    = "cloudinit"
    slot    = "scsi1"
    storage = var.storage_pool
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge_internal
    tag    = 150 # VLAN ID for the internal network
  }

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    memory = 0
    type = "serial0"
  }

  depends_on = [null_resource.upload_cloud_init_device]

  lifecycle {
    replace_triggered_by = [
      null_resource.upload_cloud_init_device
    ]
  }
}