# Recurso para criar o Security Group
resource "aws_security_group" "db_sg" {  
  name = "db_sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ajuste conforme sua necessidade para mais segurança
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Variáveis para as instâncias
variable "db_instances" {
  default = [
    {
      db_name     = "fiapxcadastro"
      db_username = "postgrescadastro"
      db_password = "postgrescadastro"
    },
    {
      db_name     = "fiapxprocessamento"
      db_username = "postgresprocessamento"
      db_password = "postgresprocessamento"
    }
  ]
}

# Criar múltiplas instâncias de RDS usando for_each
resource "aws_db_instance" "db" {
  for_each = { for idx, instance in var.db_instances : idx => instance }

  engine                 = "postgres"
  engine_version         = "14"
  db_name                = each.value.db_name
  identifier             = each.value.db_name
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  publicly_accessible    = true
  username               = each.value.db_username
  password               = each.value.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true

  lifecycle {
    ignore_changes = [db_name]
  }

  tags = {
    Name = each.value.db_name
  }
}
