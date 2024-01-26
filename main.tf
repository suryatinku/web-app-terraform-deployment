# main.tf

# Define VPC (Virtual Private Cloud)
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

# Create Subnets
resource "aws_subnet" "web_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web_subnet"
  }
}

resource "aws_subnet" "worker_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block             = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "worker_subnet"
  }
}

# Create ECS Cluster
resource "aws_ecs_cluster" "main_cluster" {
  name = "main_cluster"
}

# Create ECS Task Definitions for Main Web Application and Background Worker
resource "aws_ecs_task_definition" "web_task" {
  family                   = "web_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions    = jsonencode([{
    name  = "web_app_container",
    image = var.web_app_image,
    portMappings = [{
      containerPort = 80,
      hostPort      = 80,
    }]
  }])
}

resource "aws_ecs_task_definition" "worker_task" {
  family                   = "worker_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions    = jsonencode([{
    name  = "worker_container",
    image = var.worker_image,
  }])
}

# Create ECS Service for Main Web Application
resource "aws_ecs_service" "web_service" {
  name            = "web_app_service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.web_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets = [aws_subnet.web_subnet.id]
    security_groups = [aws_security_group.web_sg.id]
  }
  depends_on      = [aws_ecs_task_definition.web_task]
}

# Create ECS Service for Background Worker
resource "aws_ecs_service" "worker_service" {
  name            = "worker_app_service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.worker_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets = [aws_subnet.worker_subnet.id]
    security_groups = [aws_security_group.worker_sg.id]
  }
  depends_on      = [aws_ecs_task_definition.worker_task]
}

# Create RDS Database
resource "aws_db_instance" "main_db" {
  identifier          = "main-db"
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  name                = "main_db"
  username            = "db_user"
  password            = var.db_password
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}
