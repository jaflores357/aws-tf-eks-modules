# AWS EKS with Terraform

## Install Terraform

```shell
wget https://releases.hashicorp.com/terraform/0.13.0/terraform_0.13.0_linux_amd64.zip
unzip terraform_*.zip
/bin/rm terraform*.zip
sudo mv terraform /usr/local/bin/
```

## Terrafrom init and apply

### Create Dev workspace

```shell
terraform workspace new dev
```

### Download dependencies

```shell
terraform init
```

### Plan and apply 

```shell
terraform plan -out eks.terraform
terraform apply eks.terraform 
```

## Configure kubectl

### Install

```shell 
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### Setup credentials

```shell
aws eks --region us-east-2 update-kubeconfig --name dev-southsystem
```

