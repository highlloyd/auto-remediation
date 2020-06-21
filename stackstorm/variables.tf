variable subnet {
  type        = string
  default     = ""
  description = "ID of the subnet"
}

variable securitygroupids {
  type        = string
  default     = ""
  description = "Id of your vpc security group"
}

variable keyname {
  type        = string
  default     = ""
  description = "Your aws key name"
}
