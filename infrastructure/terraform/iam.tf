module "ebs_csi_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${var.project_name}-ebs-csi"

  trust_policy_permissions = {
    EksPodIdentity = {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]

      principals = [
        {
          type        = "Service"
          identifiers = ["pods.eks.amazonaws.com"]
        }
      ]
    }
  }

  policies = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  tags = {
    Project = var.project_name
  }
}