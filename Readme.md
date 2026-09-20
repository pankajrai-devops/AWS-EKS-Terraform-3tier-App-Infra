# Amazon EKS 1.35 Three tier K8S Infrastructure setup with Aurora PostgreSQL. The hard way not using the modules from Terraform but granular self written modules.
In future will add ingress-controller deployment as well. There are two ways to add that either using terraform Kubernetes and Helm provider. 
Alternatively, can use shell script to run aws command to update kubeconfig and then use kubectl and helm charts to apply ingress controller.

This repository contains native, module Terraform configurations to provision an Three tier application setup **Amazon EKS (Elastic Kubernetes Service) version 1.35** cluster integrated with a secure, highly available **Amazon Aurora PostgreSQL** database cluster. 

The infrastructure features a code that can be  compiled and validated against a local Moto mock container environment before hitting production cloud providers.


---

## 🏗 Architecture Blueprint

* **VPC Networking:** Dual-NAT public, private 3 AZ based (EKS  and compute), and isolated database subnet layers.
* **EKS Control Plane:** Deployed natively at **Kubernetes 1.35** with strict default cgroup v2 compatibility standards.
* **EKS Add-ons:** Preconfigured reference baselines for `vpc-cni`, `coredns`, `kube-proxy`, `aws-pod-identity-agent`, and storage CSI drivers ebs and efs based.
* **Database Layer:** Multi-AZ Aurora PostgreSQL cluster with automated master credential injection using AWS Secrets Manager.
* **Security Controls:** Granular cross-communication pathways linking EKS workload containers directly to Aurora endpoint groups.

---

## 📋 Module and Configuration Structure

```text
EKS-terraform/
├── main.tf                 # Core provider mappings and parent modules
├── variables.tf            # Root operational parameters and environmental toggles
├── outputs.tf              # Unified infrastructure endpoint summaries
└── modules/
    ├── network/            # Core VPC structures and private route associations
    ├── iam/                # IAM identity configurations and access boundaries
    ├── eks/                # Control plane and worker node definitions
    └── database/           # Aurora PostgreSQL cluster settings
```

---

## 🛠 Prerequisites

Before executing commands, make sure your local computer has the following tools installed:

* **Terraform:** `v1.16.0` or higher
* **AWS CLI:** Modern v2 bundle
* **Docker Desktop or Runtime:** Running container runtime daemon (required for local Moto simulation workflows) or alternatively run it with python script. 

---

## 🪵 Local Mock Testing (Using Moto)

To safely execute a plan and mock resources locally without spinning up real, costly AWS resources, execute your stack against a running Moto image.

### 1. Launch the Moto Container
Run Moto locally in a Docker container exposing port `5001`:

```bash
docker run -d --name local-moto -p 5001:5001 motoserver/moto:latest
```

### 2. Initialize and Execute
Moto updates asynchronously in memory, which often results in couldn't find resource errors if a rule tries to bind before the container completes processing the security group object. 

So, add dependencies on security group rules if it fails and Ensure that you pass is_local = var.is_local from your root main.tf into your module "eks" and module "iam" calls so the submodules can register the flag.
So in root/variables.tf add following:

```text
variable "is_local" {
  type        = bool
  default     = true # Flip to false when deploying to real AWS
  description = "Disables resources that the local Moto container cannot mock"
}
```

And to resources that show failure add following to resource blocks:
```text
count = var.is_local ? 0 : 1
```


Ensure `is_local` is set to `true` to turn off advanced cloud APIs that Moto cannot simulate (such as EKS managed add-on installations and native cloud policy mapping blocks):

```bash
terraform init
terraform plan -var="is_local=true"
terraform apply -var="is_local=true" -auto-approve
```

*Note: If you run into state validation conflicts due to testing cycles, flush your container workspace instantly via `docker restart local-moto` before rerunning.*

---

## 🚀 Real AWS Cloud Deployment

When you are ready to ship this environment layout to real AWS server instances, clear out your local variables and pass your official enterprise profile mappings.

### 1. Authenticate with AWS
Authenticate using your target enterprise profile setup:

```bash
# If utilizing IAM Identity Center / SSO mappings
aws sso login --profile prod-infra
export AWS_PROFILE="prod-infra"

# Unset any leftover mock engine overrides
unset AWS_ENDPOINT_URL

Before deploying it into producation remove the following from root/main.tf file

```text
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2       = "http://localhost:5001"
    eks       = "http://localhost:5001"
    iam       = "http://localhost:5001"
    rds       = "http://localhost:5001"
    route53   = "http://localhost:5001"
    s3        = "http://localhost:5001"
    sts       = "http://localhost:5001"
```  
```

### 2. Run the Real Deployment Pipeline
Run the initialization string cleanly. Setting `is_local = false` will automatically build your IAM role dependencies, deploy your managed Kubernetes 1.35 add-ons, and spin up live Aurora database architectures:

```bash
# Clean out local staging structures
rm -rf .terraform/ .terraform.lock.hcl

# Build infrastructure on real AWS
terraform init
terraform plan -var="is_local=false"
terraform apply -var="is_local=false"
```

---


