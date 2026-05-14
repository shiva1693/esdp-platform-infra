# COMPUTED VALUES
locals {
    cluster_name = coalesce(var.cluster_name, "${var.name_prefix}-eks")
    enable_custom_networking = length(var.pod_subnet_ids_by_az) > 0
    availability_zones = locals.enable_custom_networking ? keys(var.pod_subnet_ids_by_az) : []
    pod_subnet_ids = locals.enable_custom_networking ? values(var.pod_subnet_ids_by_az) : []
    
    #Access Entry Mapping
    admin_entries = {
        for entry in var.cluster_admins : entry_name =>{
            principal_arn = entry.principal_arn
            type = "admin"
        }
    }

    dev_entries ={
        for entry in var.cluster_devs : entry_name =>{
            principal_arn = entry.principal_arn
            type = "dev"
        }
    }

    readyonly_entries = {
        for entry in var.cluster_readonlys :entry_name =>{
            principal_arn = entry.principal_arn
            type= "readonly"
        }
    }

    #merges all three into one flat map
    all_access_entries = merge(local.admin_entries, local.dev_entries, local.readyonly_entries)
    
    # Access Scope Mapping 
    access_policy_map = {
        admin = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        dev = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
        readonly = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
    }

    access_scope_map = {
        admin = "cluster"
        dev = "cluster"
        readonly = "cluster"
    }

    #CI Access Mapping
    ci_access_entry = var.ci_role_arn != null ? {
        "ci-deployer" = {
            principal_arn = var.ci_role_arn
            type = "dev"
        }
    } : {}

    #Addon Configuration
    eks_addons = {
        vpc_cni = {
            version = try(var.addon_versions.vpc_cni, null)
            needs_pod_identity = true
            service_account_name = "aws-node"
            namespace = "kube-system"
        }
        core-dns = {
            version = try(var.addon_versions.code_dns, null)
            needs_pod_identity =false
            service_account_name = "coredns"
            namespace = "kube-system"
        }
        kube-proxy = {
            version = try(var.addon_versions.kube_proxy, null)
            needs_pod_identity = false
            service_account_name = "kube-proxy"
            namespace = "kube-system"
        }
        eks-pod-identity-agent = {
            version = try(var.addon_versions.eks_pod_identity_agent, null)
            needs_pod_identity = true
            service_account_name = "eks-pod-identity-agent"
            namespace = "kube-system"
        }
    }

#Filter Addons Needing Pod Identity
#Only for entries where needs_pod_identity = true
    addons_with_pod_identity = {
        for name, config in local.eks_addons :
        name => config 
        if config.needs_pod_identity
    }

#Node Groups Confirguration
    node_groups = {
        system ={
            intance_types = var.system_node_config.instance_types
            desired_size = var.system_node_config.desired_size
            max_size = var.system_node_config.max_size
            min_size = var.system_node_config.min_size
            disk_size = var.system_node_config.disk_size
            taints = [
                {
                    key = "CriticalAddonsOnly" #Standard taint key for critical addons
                    value= "true"
                    effect = "NO_SCHEDULE"
                }
            ]
            labels ={
                "role" = "system"
                "node.kubernetes.io/lifecycle" = "on-demand"
            }
        }


        app = {
            instance_types= var.app_node_config.instance_types
            desired_size = var.app_node_config.desired_size
            max_size = var.app_node_config.max_size
            min_size =var.app_node_config.min_size
            disk_size = var.app_node_config.disl_size
            taints = []
            labels = {
                "role" = "application"
                "node.kubernetes.io/lifecycle" = "on-demand"
            }
        }
    }

    #Tags for Node Groups 
    #EKS auto-discovery tags is required for 
    # Cluster AutoScaler to find node groupd
    #Karpenter to discover capacity & AWS LB to find subnets
    cluster_autoscaler_tags ={
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
    }

}

