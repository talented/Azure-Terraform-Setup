# Provisioning Azure VMs and various resources with Terraform
> This terraform setup creates 2 VMs on Azure with the following resources. The purpose of this setup is to install a Kubernetes cluster with Kubeadm as a dev K8s environment. 
&nbsp;

| Resource Name | Notes |
| :----------: | :------ |
| Resource group |  |
| 2x Virtual Machine | Count of VMs can be updated in tfvars file |
| Storage Account |  |
| TLS private key |	saved locally for SSH |
| Virtual Network |  |
| 1x Subnet | Option for adding another subnet |
| 2x Public IP | Incremental depends on the number of VMs |
| Network Security Group | Port 22 and 6443 inbound access allowed as default for K8s |
| 2x Network Interface | Incremental depends on the number of VMs

&nbsp;
### SSH into VMs
Configure a DNS name for each VM on Azure cloud portal or use public IP addresses to login via SSH

```shell
ssh -i ubuntu_ssh_key.pem azureuser@DNS_NAME
```

