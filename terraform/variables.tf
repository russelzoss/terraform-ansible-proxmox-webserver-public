variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
}

variable "vm_template" {
  description = "Name of the VM template"
  default     = "ubuntu-24.10-template"
}

variable "node_name" {
  description = "Proxmox node name"
  default     = "proxmox"
}

variable "storage_pool" {
  description = "Proxmox storage pool for VMs"
  default     = "local"
}

variable "network_bridge_public" {
  description = "Public network bridge"
  default     = "vmbr0"
}

variable "network_bridge_internal" {
  description = "Internal network bridge"
  default     = "vmbr1"
}

variable "webserver_hostname" {
  description = "Hostname for the webserver VM"
  type        = string
}

variable "webserver_public_ip" {
  description = "Public IP address for the webserver"
  type        = string
}

variable "webserver_public_mac" {
  description = "Public MAC address for the webserver"
  type        = string
}

variable "webserver_private_ip" {
  description = "Private IP address for the webserver"
  type        = string
}

variable "gateway" {
  description = "Gateway IP for the public network"
  type        = string
  default     = null
}

variable "nameservers" {
  description = "List of nameservers for DNS resolution"
  type        = list(string)
  default     = []
}

variable "private_subnet" {
  description = "Subnet for the private network in CIDR notation"
  type        = string
}

variable "device_hostname" {
  description = "Hostname for the device VM"
  type        = string
}

variable "device_private_ip" {
  description = "Private IP address for the device VM"
  type        = string
}

variable "device_public_ip" {
  description = "Public IP address for the device VM"
  type        = string
  default     = ""
}

variable "user" {
  description = "Username for the VM"
  type        = string
}

variable "ssh_keys" {
  description = "List of SSH public keys for user authentication"
  type        = list(string)
}

variable "hashed_password" {
  description = "Hashed password for the VM user"
  type        = string
}
