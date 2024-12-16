output "webserver_network_config" {
  value = local.webserver_network_config
  description = "Dynamically generated cloud-init network configuration for the web server."
}

output "webserver_user_data" {
  value = local.webserver_user_data
  description = "Dynamically generated cloud-init user data for the web server."
}

output "device_network_config" {
  value = local.device_network_config
  description = "Dynamically generated cloud-init network configuration for the device."
}

output "device_user_data" {
  value = local.device_user_data
  description = "Dynamically generated cloud-init user data for the device."
}

