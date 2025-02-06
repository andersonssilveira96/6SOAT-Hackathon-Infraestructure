variable "region" {
  default  = "us-east-1"
}

variable "regionDefault" {
  default = "us-east-1"
}

variable "eksName" {
  default = "eks-fiapx"
}

variable "eksVersion" {
  default = "1.29"
}

variable "serviceIpv4" {
  default = "10.100.0.0/16"
}

variable "nodeDiskSize" {
  default = 20
}

variable "nodeInstanceType" {
  default = "c3.xlarge"
}

variable "nodeCapacityType" {
  default = "ON_DEMAND"
}

variable "nodeAmiType" {
  default = "AL2_x86_64"
}

variable "ebsAddonName" {
  default = "aws-ebs-csi-driver"
}

variable "ebsAddonVersion" {
  default = "v1.28.0-eksbuild.1"
}

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
  default     = "fiapxfilesbucket"
}