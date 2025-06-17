resource "aws_eks_cluster" "main" {
  name     = "${local.project_name}-cluster"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids         = aws_subnet.main[*].id
    security_group_ids = [aws_security_group.cluster.id]
  }
}

resource "aws_launch_template" "eks_spot" {
  name_prefix   = var.launch_template_name
  image_id      = data.aws_ami.eks.id
  instance_type = var.node_instance_type

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "eks-spot-instance" })
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_max_price
      spot_instance_type = "persistent"
      instance_interruption_behavior = "stop"
    }
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.project_name}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.main[*].id

  launch_template {
    id      = aws_launch_template.eks_spot.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.desired_capacity
    min_size     = var.desired_capacity
  }

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.nodes.id]
  }
}
