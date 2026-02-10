variable "viuser" {}
variable "vipassword" {}
variable "viserver" {
  default = "vcs1.local.domain"
}

// default VM name in vSphere and its hostname
variable "vmname" {
  default = "test-vm"
}

// default Resource Pool
variable "vmrp" {
  default = "YOUR_RP"
}

// default VM domain for guest customization
variable "vmdomain" {
  default = "local.domain"
}

// default datastore to deploy vmdk
variable "vmdatastore" {
  default = "DS_SILVER_01"
}

// default VM Template
variable "vmtemp" {
  default = "CENTOS-TEMP"
}

// map of the datastore clusters (vmdatastore = "vmdscluster")
variable "vmdscluster" {
  type = "map"
  default = {
    DS_SILVER_01 = "DS_CLUSTER_SILVER"
    DS_SILVER_02 = "DS_CLUSTER_SILVER"
    DS_GOLD_01 = "DS_CLUSTER_GOLD"
    DS_GOLD_02 = "DS_CLUSTER_GOLD"
  }
}