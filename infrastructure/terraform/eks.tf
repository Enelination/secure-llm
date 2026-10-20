module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project_name}-cluster"
  kubernetes_version = var.cluster_version

  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  access_entries = {
    admin = {
      principal_arn = data.aws_caller_identity.current.arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  addons = {
    coredns = {}

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }

    eks-pod-identity-agent = {}

    aws-ebs-csi-driver = {
      pod_identity_association = [
        {
          role_arn        = module.ebs_csi_iam_role.arn
          service_account = "ebs-csi-controller-sa"
        }
      ]
    }
  }

  eks_managed_node_groups = {
    system = {
      name = "${var.project_name}-system"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      capacity_type = "ON_DEMAND"

      disk_size = 50

      labels = {
        workload = "system"
      }
    }

    llm_cpu = {
      name = "${var.project_name}-llm-cpu"

      instance_types = ["m7i.2xlarge"]

      min_size     = 0
      max_size     = 1
      desired_size = 0

      capacity_type = "ON_DEMAND"

      disk_size = 100

      labels = {
        workload = "llm-cpu"
      }

      taints = {
        llm = {
          key    = "workload"
          value  = "llm-cpu"
          effect = "NO_SCHEDULE"
        }
      }
    }

    gpu = {
      name = "${var.project_name}-gpu"

      instance_types = ["g5.xlarge"]

      min_size     = 0
      max_size     = 1
      desired_size = 0

      capacity_type = "ON_DEMAND"

      disk_size = 100

      ami_type = "AL2023_x86_64_NVIDIA"

      labels = {
        workload    = "llm"
        accelerator = "nvidia"
      }

      taints = {
        llm = {
          key    = "workload"
          value  = "llm"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = {
    Project = var.project_name
  }
}