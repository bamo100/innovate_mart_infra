resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow inbound traffic to databases from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.source_cidr]
  }

  ingress {
    description = "PostgreSQL access from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.source_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = var.database_subnets
}

# Passwords
resource "random_password" "mysql_pass" {
  length  = 16
  special = false
}

resource "random_password" "postgres_pass" {
  length  = 16
  special = false
}

# MySQL
resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "retailapp"
  username               = "dbadmin"
  password               = random_password.mysql_pass.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}

# PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-postgres"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "retailapp"
  username               = "dbadmin"
  password               = random_password.postgres_pass.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}

# DynamoDB
resource "aws_dynamodb_table" "carts" {
  name         = "retail-app-carts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }
}

# Store credentials securely in AWS Secrets Manager (Requirement 4.2)
resource "aws_secretsmanager_secret" "mysql_secret" {
  name                    = "${var.project_name}/mysql-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "mysql_secret_version" {
  secret_id = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.mysql_pass.result
    host     = aws_db_instance.mysql.endpoint
    dbname   = aws_db_instance.mysql.db_name
  })
}

resource "aws_secretsmanager_secret" "postgres_secret" {
  name                    = "${var.project_name}/postgres-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "postgres_secret_version" {
  secret_id = aws_secretsmanager_secret.postgres_secret.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.postgres_pass.result
    host     = aws_db_instance.postgres.endpoint
    dbname   = aws_db_instance.postgres.db_name
  })
}
