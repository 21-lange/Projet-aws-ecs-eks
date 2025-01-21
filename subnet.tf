// création d'un VPC 
resource "aws_vpc" "terraform" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform"
  }
}

// création de sous réseau

resource "aws_subnet" "subnet-01" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "172.16.1.0/24"

  tags = {
    Name = "subnet-01"
  }
}
// création du 2ème sous réseau
resource "aws_subnet" "subnet-02" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "172.16.2.0/24"

  tags = {
    Name = "subnet-02"
  }
}
//création d'une gateway
resource "aws_internet_gateway" "gatewayterraform" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "gatewayterraform"

  }
  
}
//ajout d'une table de routage dans internet gateway
resource "aws_route_table" "routerraform" {
  vpc_id = aws_vpc.terraform.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gatewayterraform.id
  }
  
  tags = {
    Name = "routerraform"
  }
}
resource "aws_route_table_association" "sub1" {
  subnet_id      = aws_subnet.subnet-01.id
  route_table_id = aws_route_table.routerraform.id
}

resource "aws_route_table_association" "sub2" {
  subnet_id      = aws_subnet.subnet-02.id
  route_table_id = aws_route_table.routerraform.id
}

// création d'un groupe de sécurité
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terraform.id

  tags = {
    Name = "allow_tls"
  }
}

//ajout d'une règle HTTP
  resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0" // depuis n'importe quelle source
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
// création d'un repository 
resource "aws_ecr_repository" "grp3" {
  name                 = "rep_grp3"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
// création d'un cluster
resource "aws_ecs_cluster" "cluster_grp3" {
  name = "cluster_grp3"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  // création d'une tâche de défintion  
}
resource "aws_ecs_task_definition" "ecs_task_definition" {
 family             = "my-ecs-task"
 network_mode       = "awsvpc"
 execution_role_arn = "arn:aws:iam::048306789197:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
 cpu                = 256
 runtime_platform {
   operating_system_family = "LINUX"
   cpu_architecture        = "X86_64"
 }
 container_definitions = jsonencode([
   {
     name      = "dockergs"
     image     = "048306789197.dkr.ecr.us-east-1.amazonaws.com/rep_grp3:latest"
     cpu       = 256
     memory    = 512
     essential = true
     portMappings = [
       {
         containerPort = 80
         hostPort      = 80
         protocol      = "tcp"
       }
     ]
   }
 ])
}
 // création d'un service 
 /*resource "aws_ecs_service" "ecs_service" {
 name            = "my-ecs-service"
 cluster         = aws_ecs_cluster.cluster_grp3.id
 task_definition = aws_ecs_task_definition.ecs_task_definition.arn
 desired_count   = 2

 network_configuration {
   subnets         = [aws_subnet.subnet-01.id, aws_subnet.subnet-02.id]
   security_groups = [aws_security_group.allow_tls.id]
 }

 force_new_deployment = true
 placement_constraints {
   type = "distinctInstance"
 }

 triggers = {
   redeployment = timestamp()
 }

 capacity_provider_strategy {
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
   weight            = 100
 }

 load_balancer {
   target_group_arn = aws_lb_target_group.ecs_tg.arn
   container_name   = "dockergs"
   container_port   = 80
 }

 depends_on = [aws_autoscaling_group.ecs_asg]
}
}*/