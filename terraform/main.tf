terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-3"
  profile = "devops-project"
}

# ==================== ECR ====================
resource "aws_ecr_repository" "app" {
  name                 = "devops-free-tier-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# ==================== RDS Security Group ====================
resource "aws_security_group" "rds_sg" {
  name        = "devops-free-tier-rds-sg"
  description = "Allow EKS nodes to access RDS"
  vpc_id      = "vpc-0f7c82a61ba335a0c"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==================== RDS Subnet Group (nouveau nom) ====================
resource "aws_db_subnet_group" "main" {
  name       = "devops-free-tier-db-subnet-v2"   # ← Nom changé
  subnet_ids = [
    "subnet-0284a906cac4f46ad",   # Private EUWEST3A
    "subnet-06a659625e0401fe3"    # Private EUWEST3B
  ]
}

# ==================== RDS Instance ====================
resource "aws_db_instance" "postgres" {
  identifier           = "devops-free-tier-db"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16"
  db_name              = "appdb"
  username             = "appuser"
  password             = "SuperSecret123!"

  skip_final_snapshot  = true
  publicly_accessible  = false
  apply_immediately    = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}

# ==================== OUTPUTS ====================
output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}