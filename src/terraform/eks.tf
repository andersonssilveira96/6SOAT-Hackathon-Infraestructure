data "aws_iam_role" "name" {
  name = "LabRole"
}

data "aws_vpcs" "selected" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.selected.ids[0]]
  }
}

data "aws_subnet" "selected" {
  for_each = toset(data.aws_subnets.selected.ids)

  id = each.value
}

data "aws_security_group" "eks-sg" {
  id = aws_eks_cluster.eks-fiapx.vpc_config[0].cluster_security_group_id
}

resource "aws_eks_cluster" "eks-fiapx" {

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = var.serviceIpv4
  }

  name     = var.eksName
  role_arn = data.aws_iam_role.name.arn
  version  = var.eksVersion

  vpc_config {
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [for subnet in data.aws_subnet.selected : subnet.id if subnet.availability_zone != "us-east-1e"]
  }
  
  logging {
    cluster_logging {
      enabled = true
      types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    }
  }
}

resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/my-eks-cluster/logs"
  retention_in_days = 30  # Tempo de retenção dos logs
}

resource "aws_cloudwatch_metric_alarm" "eks_cpu_alarm" {
  alarm_name          = "eks-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarme para uso alto de CPU no EKS"
  alarm_actions       = [aws_sns_topic.eks_alerts.arn]
}

resource "aws_iam_role_policy_attachment" "eks_logs" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_eks_node_group" "fiapx-node" {
  ami_type      = var.nodeAmiType
  capacity_type = var.nodeCapacityType
  cluster_name  = var.eksName
  disk_size     = var.nodeDiskSize

  instance_types = [
    var.nodeInstanceType
  ]

  node_group_name = "fiapx-node"
  node_role_arn   = data.aws_iam_role.name.arn
  subnet_ids      = [for subnet in data.aws_subnet.selected : subnet.id if subnet.availability_zone != "us-east-1e"]
  version         = var.eksVersion

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  depends_on = [aws_eks_cluster.eks-fiapx]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = var.eksName
  addon_name                  = var.ebsAddonName
  addon_version               = var.ebsAddonVersion
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"

  depends_on = [aws_eks_node_group.fiapx-node]
}


resource "aws_security_group" "eks-sg" {
  name        = "eks-default-sg"
  description = "Default security group for the EKS cluster"
  vpc_id      = aws_eks_cluster.eks-fiapx.vpc_config[0].vpc_id
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.eksName
  addon_name                  = "vpc-cni"
  addon_version               = "v1.16.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.fiapx-node]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = var.eksName
  addon_name                  = "kube-proxy"
  addon_version               = "v1.29.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_addon.vpc_cni
  ]
}

resource "aws_eks_addon" "core_dns" {
  cluster_name                = var.eksName
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.4"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_addon.vpc_cni
  ]
}