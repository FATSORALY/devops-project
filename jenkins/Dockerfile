FROM jenkins/jenkins:2.492.3-jdk17

USER root

# ── Dépendances système ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl unzip git ca-certificates \
    gnupg lsb-release apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# ── Docker CLI ────────────────────────────────────────────────────────────────
RUN curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /usr/share/keyrings/docker.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] \
       https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# ── kubectl ───────────────────────────────────────────────────────────────────
RUN KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt) \
    && curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && install -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# ── Helm ─────────────────────────────────────────────────────────────────────
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ── AWS CLI v2 ────────────────────────────────────────────────────────────────
RUN curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

# ── Terraform ─────────────────────────────────────────────────────────────────
RUN TF_VERSION="1.8.3" \
    && curl -sL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
       -o terraform.zip \
    && unzip -q terraform.zip \
    && install -m 0755 terraform /usr/local/bin/terraform \
    && rm terraform.zip terraform

# ── Trivy ─────────────────────────────────────────────────────────────────────
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

# ── Ajouter jenkins au groupe docker ─────────────────────────────────────────
RUN groupadd -f docker && usermod -aG docker jenkins

USER jenkins

# ── Plugins Jenkins (installation simplifiée sans versions spécifiques) ──────
RUN jenkins-plugin-cli --plugins \
    git \
    github \
    github-branch-source \
    workflow-aggregator \
    pipeline-stage-view \
    docker-workflow \
    kubernetes \
    kubernetes-credentials \
    aws-credentials \
    amazon-ecr \
    credentials-binding \
    blueocean \
    prometheus \
    configuration-as-code

# Désactiver le wizard de setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"