#!/usr/bin/env bash
# =============================================================================
# build-push-jenkins.sh
# Build l'image Jenkins custom et la pousse vers ECR eu-west-3
# Usage : bash build-push-jenkins.sh
# =============================================================================

set -euo pipefail

AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_NAME="devops-project/jenkins"
TAG=$(date +%Y%m%d-%H%M)

GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $*"; }

log "Account : $AWS_ACCOUNT_ID"
log "Registry: $ECR_REGISTRY"
log "Tag     : $TAG"

# Créer le repo ECR s'il n'existe pas
log "Vérification du repo ECR..."
aws ecr describe-repositories --repository-names "$IMAGE_NAME" \
    --region "$AWS_REGION" 2>/dev/null || \
aws ecr create-repository \
    --repository-name "$IMAGE_NAME" \
    --region "$AWS_REGION" \
    --image-scanning-configuration scanOnPush=true

# Login ECR
log "Login ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Build
log "Build de l'image Jenkins custom..."
docker build \
    --platform linux/amd64 \
    -t "${IMAGE_NAME}:${TAG}" \
    -t "${IMAGE_NAME}:latest" \
    -f jenkins/Dockerfile \
    jenkins/

# Tag + Push
log "Push vers ECR..."
docker tag "${IMAGE_NAME}:${TAG}"    "${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}"
docker tag "${IMAGE_NAME}:latest"    "${ECR_REGISTRY}/${IMAGE_NAME}:latest"
docker push "${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}"
docker push "${ECR_REGISTRY}/${IMAGE_NAME}:latest"

log "✅ Image pushée : ${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}"
echo ""
echo -e "${CYAN}Mettre à jour jenkins-k8s.yaml :${NC}"
echo "  image: ${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}"