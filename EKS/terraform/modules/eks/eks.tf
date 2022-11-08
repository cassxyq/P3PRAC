resource "aws_eks_cluster" "eks-cluster" {
 name = "${var.prefix}-cluster"
 role_arn = aws_iam_role.eks-cluster-role.arn

 vpc_config {
  subnet_ids = [var.public_subent_id, var.private_subnet_id] #需要根据ouput改动 查清楚要在哪个subnet
 }

 depends_on = [
  aws_iam_role.eks-cluster-role
 ]
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.prefix}-nodegroup"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [var.public_subnet_id, var.private_subnet_id] #同上
  instance_types = ["${var.instance_type}"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}