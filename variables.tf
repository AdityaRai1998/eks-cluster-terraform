variable "region" {
  description = "The name of the region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "adi-cluster"
}

variable "iam_role_name" {
  description = "The IAM role name of the EKS cluster"
  type        = string
  default     = "eks-cluster-role"
}

variable "iam_role_name_node_group" {
  description = "The IAM role name of the Node Group"
  type        = string
  default     = "eks-node-role"
}

variable "node_group_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "adi-node-group"
}

variable "node_instance_type" {
  description = "The instance type of the EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "subnet_ids" {
  description = "List of subnet IDs where the EKS cluster will be deployed"
  type        = list(string)
  default     = ""
}

variable "security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = ""
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Project     = "Test"
    Owner       = "Capital Group"
  }
}

variable "desired_node_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 5
}

variable "max_node_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 5
}

variable "min_node_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 5
}
