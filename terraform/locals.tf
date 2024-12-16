locals {
  proxmox_ip = regex("^https?://([0-9\\.]+)", var.proxmox_endpoint)[0]
}
