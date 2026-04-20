# DevOps Project — AWS eu-west-3

Stack complète : Kubernetes · AWS EKS · Jenkins · Terraform · Docker · Grafana · Prometheus

## Prérequis WSL2

```bash
sudo apt update && sudo apt install -y awscli kubectl helm terraform unzip
aws configure   # Region : eu-west-3
```

## 🚀 Démarrage rapide

### 1. Dev local (sans AWS)

```bash
docker-compose up -d
# App     → http://localhost:3000
# Grafana → http://localhost:3001  (admin / admin123)
# Prometheus → http://localhost:9090
```

### 2. Déploiement AWS

```bash
# Créer le bucket S3 pour le state Terraform
aws s3 mb s3://devops-tf-state-VOTREPRENOM --region eu-west-3

# Mettre à jour le bucket dans terraform/main.tf (ligne backend "s3")

# Déployer l'infrastructure
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# Configurer kubectl
aws eks update-kubeconfig --region eu-west-3 --name devops-cluster

# Vérifier les nodes
kubectl get nodes
```

### 3. Jenkins — Credentials à configurer

| ID Credential         | Type        | Valeur                          |
|-----------------------|-------------|---------------------------------|
| `ECR_REGISTRY_URL`    | Secret text | URL ECR (output Terraform)      |
| `kubeconfig-eks`      | Secret file | `~/.kube/config` après EKS setup|

### 4. Accès Grafana

```bash
# Port-forward depuis WSL2
kubectl port-forward -n monitoring svc/grafana 3001:80 &
# → http://localhost:3001  (admin / GrafanaAdmin123!)
```

Dashboards pré-chargés :
- **Kubernetes Cluster** (ID 7249)
- **Node Exporter Full** (ID 1860)
- **Kubernetes Pods** (ID 6417)

## Coûts Free Tier estimés

| Service         | Coût          |
|-----------------|---------------|
| EC2 t2.micro    | Gratuit 1 an  |
| EKS cluster     | ~73 $/mois    |
| Nodes t3.small SPOT | ~4 $/mois |
| ECR (≤500MB)    | Gratuit       |
| S3              | Gratuit       |

> **Tip :** Éteindre les nodes EKS le soir avec `eksctl scale nodegroup --nodes=0` économise ~80% des coûts.
