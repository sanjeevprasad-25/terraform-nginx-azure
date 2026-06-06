locals {
  sptechno_web_nsg = {
    "allow_ssh" = {
        destination_port= 22
        priority= 100
        description= "Allow SSH"
            }
    "allow_http" = {
        destination_port = 80
        priority = 110
        description =  "Allow HTTP"
            }        
    "allow_https" = {
        destination_port = 443
        priority = 120
        description =  "Allow HTTPS"
            }
    }
}