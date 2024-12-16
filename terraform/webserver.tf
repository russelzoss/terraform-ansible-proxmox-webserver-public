locals{
  webserver_network_config = templatefile("${path.module}/cloud-init/network-config.tftpl", {
      public_ip               = var.webserver_public_ip,
      gateway                 = var.gateway,
      nameservers             = var.nameservers,
      private_ip              = var.webserver_private_ip,
      private_subnet          = var.private_subnet
    })
  webserver_network_config_hash = sha256(local.webserver_network_config)

  webserver_user_data = templatefile("${path.module}/cloud-init/user-data.tftpl", {
    hostname        = var.webserver_hostname,
    user            = var.user,
    ssh_keys        = var.ssh_keys,
    hashed_password = var.hashed_password
  })
  webserver_user_data_hash      = sha256(local.webserver_user_data)    
}

resource "null_resource" "upload_cloud_init_webserver" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = local.proxmox_ip
  }

  triggers = {
    network_config_hash = local.webserver_network_config_hash
    user_data_hash      = local.webserver_user_data_hash
  }

  provisioner "file" {
    content     = local.webserver_network_config
    destination = "/var/lib/vz/snippets/${var.webserver_hostname}-network-config.yaml"
  }
  
  provisioner "file" {
    content     = local.webserver_user_data
    destination = "/var/lib/vz/snippets/${var.webserver_hostname}-user-data.yaml"
  }  
}

resource "proxmox_vm_qemu" "webserver" {
  target_node = var.node_name
  clone       = var.vm_template
  name        = var.webserver_hostname
  cicustom    = "network=local:snippets/${var.webserver_hostname}-network-config.yaml,user=local:snippets/${var.webserver_hostname}-user-data.yaml"

  cores   = 2
  memory  = 2048
  sockets = 1
  scsihw  = "virtio-scsi-pci"
  os_type = "cloud-init"


  disk {
    type    = "disk"
    slot    = "scsi0"
    storage = var.storage_pool
    format  = "raw"
    size    = "20G"
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

  network {
    id      = 1
    model   = "virtio"
    bridge  = var.network_bridge_public
    macaddr = var.webserver_public_mac
  }

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    memory = 0
    type = "serial0"
  }

  depends_on = [null_resource.upload_cloud_init_webserver]

  lifecycle {
    replace_triggered_by = [
      null_resource.upload_cloud_init_webserver
    ]
  }
}