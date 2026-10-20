resource "aws_iam_policy" "aws_lb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/policies/aws-load-balancer-controller-iam-policy.json")

  tags = {
    Project = var.project_name
  }
}

module "aws_lb_controller_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${var.project_name}-aws-lb-controller"

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
    AWSLoadBalancerControllerIAMPolicy = aws_iam_policy.aws_lb_controller.arn
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_eks_pod_identity_association" "aws_lb_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = module.aws_lb_controller_iam_role.arn
}

resource "aws_acm_certificate" "wildcard" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = var.project_name
  }
}
