# Nomad and EKS Setup

## Requirements

- You must have an AWS account and a Grafana Stack created
- Have `packer`, `nomad`, `terraform`, `kubectl`, `helm`, `awscli`, `docker`, `k6` installed

## Steps

- Replace the empty values with your own values within the code
- Build your image using packer first
- It is up to you how you deploy this code to AWS
- Pass the ami-id to terraform and run terraform apply
- Refer below for the eks deployment
- For Nomad, use any Public API or build your own and deploy using the reference spec file (I used a simple FastAPI service)
- Use the automation folder to run the k6 automation scripts (ensure you have a grafana account first to get your tokens)
- Build your own dashboard for comparison

Use the following for the eks deployments:

```sh
aws eks update-kubeconfig --name eks --region eu-west-1
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.1/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.1/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add grafana https://grafana.github.io/helm-charts
helm install alloy grafana/alloy -f values.yaml
helm install --values cs.yaml consul hashicorp/consul --create-namespace --namespace consul
kubectl apply -f traefik
```

> Don't hesitate to contact me if you need any help.
