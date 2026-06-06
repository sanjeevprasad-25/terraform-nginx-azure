variable "rg_name" {
    type = string
    description = "This is resource group name"
  }
variable "rg_location" {
    type = string
    description = "This is resource group location"
  }  
variable "rg_env" {
    type = string
    description = "This is resource group environment"
  }  
variable "web_net" {
    type = string
    description = "This is virtual network name"
  } 
variable "web_sn" {
    type = string
    description = "This is subnet name"
  }  
 variable "web_vm_password" {
    type = string
    description = "This is vm password"
  }     