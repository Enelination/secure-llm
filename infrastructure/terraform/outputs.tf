output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "ecr_repositories" {
  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }
}
output "acm_certificate_arn" {
  value = aws_acm_certificate.wildcard.arn
}

output "acm_validation_records" {
  value = [
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ]
}
