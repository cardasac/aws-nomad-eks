locals {
  create_eks = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.26"
  create  = local.create_eks

  cluster_name                             = local.name
  cluster_version                          = "1.31"
  kms_key_deletion_window_in_days          = 7
  vpc_id                                   = module.network.vpc_id
  subnet_ids                               = module.network.private_subnet_ids
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    ami_type      = "AL2023_ARM_64_STANDARD"
    ebs_optimized = true
  }

  eks_managed_node_groups = {
    consul = {
      name           = "consul"
      instance_types = ["t4g.medium"]

      min_size     = 1
      max_size     = 9
      desired_size = 3
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    "Cluster" = "kubernetes-obs"
  }
}

module "ebs_csi_driver_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name_prefix      = "${local.name}-ebs-csi-driver-"
  attach_ebs_csi_policy = true
  create_role           = local.create_eks

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = ">= 1.19"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }

  aws_load_balancer_controller = {
    set = [{
      name  = "enableServiceMutatorWebhook"
      value = "false"
    }]
  }
  enable_metrics_server               = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  external_dns_route53_zone_arns      = [data.aws_route53_zone.primary_private.arn]
  enable_cert_manager                 = true
  cert_manager = {
    wait = true
  }
  cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.primary_private.arn]

  tags = {
    Environment = terraform.workspace
  }
}
