##################### Azure Info ######################

# victim company name
variable "owner" {
  type        = string
  description = "This is the main naming convention for objects within Azure"
  default = "Patch"
  }

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resources will be created"
  default     = "West US 2"
}

