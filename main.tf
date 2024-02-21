# Define provider
provider "aws" {
  region = var.region 
}

# Applying Validation Rule on the tags
locals {
  valid_tags = length(var.tags) == 5 ? true : false
}

# Applying Validation Rule on the tags
locals {
  valid_tags = length(var.tags) == 20 && contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Project") && contains(keys(var.tags), "Owner") && var.tags["Environment"] == "Production" && var.tags["Project"] == "Test" && var.tags["Owner"] == "Capital Group"
}

# Defining EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  count    = local.valid_tags ? 1 : 0  #  If valid_tags is true, the cluster will be created once (count = 1), otherwise, it will not be created (count = 0).
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids 
  }
}

# Define IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Attach IAM policies to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Defining node group
resource "aws_eks_node_group" "my_node_group" {
  count            = local.valid_tags ? 1 : 0       # If valid_tags is true, the node group will be created once (count = 1), otherwise, it will not be created (count = 0).
  cluster_name     = aws_eks_cluster.my_cluster.name
  node_group_name  = var.node_group_name
  node_role_arn    = aws_iam_role.eks_node_role.arn

  scaling_config {
    desired_size = var.desired_node_size
    max_size     = var.max_node_size
    min_size     = var.min_node_size
  }

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "Latest"
  }
}

# Define IAM role for EKS nodes
resource "aws_iam_role" "eks_node_role" {
  name               = var.iam_role_name_node_group
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach IAM policies to the node role
resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# Define launch template for nodes
resource "aws_launch_template" "my_launch_template" {
  count         = local.valid_tags ? 1 : 0
  name_prefix   = "my-launch-template-"
  image_id      = data.aws_ami.eks.id
  instance_type = var.node_instance_type

  dynamic "tag_specifications" {
    for_each = var.tags

    content {
      resource_type = "instance"
      tags          = {
        Environment = tag_specifications.value
        Project     = tag_specifications.value
        Owner       = tag_specifications.value
        ClusterName = tag_specifications.value
        NodeRole    = tag_specifications.value
      }
    }
  }
}

# Define data source for EKS AMI
data "aws_ami" "eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-*-amazon-linux-2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
