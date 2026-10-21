resource "aws_iam_policy" "external_secrets" {
  name = "${var.project_name}-external-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadProjectSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*",
        ]
      },
    ]
  })

  tags = {
    Project = var.project_name
  }
}

module "external_secrets_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "${var.project_name}-external-secrets"

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
    ExternalSecretsIAMPolicy = aws_iam_policy.external_secrets.arn
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = module.eks.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = module.external_secrets_iam_role.arn
}
