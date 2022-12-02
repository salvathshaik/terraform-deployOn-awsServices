#We also need to create an RDS DB subnet group. DB subnet is a collection of subnets
resource "aws_db_subnet_group" "terraform-rds-subgrp" {
  name       = "main"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  tags = {
    Name = "Subnet group for RDS"
  }
}

#and subnet group for ECACHE
resource "aws_elasticache_subnet_group" "terraform-ecache-subgrp" {
  name       = "terraform-ecache-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  #tags ={ #this filed is not present here so commenting
  #	Name = “Subnet group for ECACHE”
  #}
}

#now let’s create RDS database instance
resource "aws_db_instance" "terraform-rds" {
  allocated_storage      = 20 #20 GB for this RDS service
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.6.34"
  instance_class         = "db.t2.micro"
  db_name                = var.dbname #name is deprricated so using db_name
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql5.6"
  multi_az               = "false"
  publicly_accessible    = "false"
  skip_final_snapshot    = true #this option will save you some money , when you practice RDS we will end up lots of snapshots so this option will not allow it to do that
  db_subnet_group_name   = aws_db_subnet_group.terraform-rds-subgrp.name
  vpc_security_group_ids = [aws_security_group.terraform-backend-sg.id]
}

#now create the elastic cache
resource "aws_elasticache_cluster" "terraform-elastic-cache" {
  cluster_id           = "terraform-elastic-cache"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.5" #you can find this in aws doc
  port                 = 11211
  security_group_ids   = [aws_security_group.terraform-backend-sg.id] #the same we have given for RDS
  subnet_group_name    = aws_elasticache_subnet_group.terraform-ecache-subgrp.name
}

#now active MQ #rabbit MQ
resource "aws_mq_broker" "terraform-rmq" {
  broker_name        = "terraform-rmq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.15.0"
  host_instance_type = "mq.t2.micro"
  security_groups    = [aws_security_group.terraform-backend-sg.id]
  subnet_ids         = [module.vpc.private_subnets[0]] #we don't have subnet group concept here we can use subnet IDs and subnet IDs is a list and we get single instance so one subnet ID should be fine

  user {
    username = var.rmquser
    password = var.rmqpass
  }
}
