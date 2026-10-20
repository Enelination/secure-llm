# GPU node group for LLM inference
# Kept at 0 nodes until we are ready to incur GPU costs.

locals {
  gpu_node_group = {
    gpu = {
      name = "${var.project_name}-gpu"

      instance_types = ["g5.xlarge"]

      min_size     = 0
      max_size     = 1
      desired_size = 0

      capacity_type = "ON_DEMAND"

      disk_size = 100

      ami_type = "AL2023_x86_64_STANDARD"

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
}
