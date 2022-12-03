resource "aws_security_group" "terraform-bean-elb-sg" {
  name        = "terraform-bean-elb-sg"
  description = "security group for bean-elb"
  vpc_id      = module.vpc.vpc_id

  egress { #ouut bound rule
    from_port   = 0
    protocol    = "-1" #from any protocol like ftp,http or any
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #it allows all the outbound traffic anywhere
  }
  ingress {
    from_port   = 80
    protocol    = "tcp" #from any protocol like ftp,http or any
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"] #it allows all the outbound traffic anywhere
  }
}

#and now in same file we will launch SG for bastion host
resource "aws_security_group" "terraform-bastion-sg" {
  name        = "terraform-bastion-sg"
  description = "security group for bastionisioner ec2 instance"
  vpc_id      = module.vpc.vpc_id

  egress { #out bound rule
    from_port   = 0
    protocol    = "-1" #from any protocol like ftp,http or any
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #it allows all the outbound traffic anywhere
  }
  # for batsion we need to be careful in inbound traffic
  ingress {
    from_port   = 22
    protocol    = "tcp" #from any protocol like ftp,http or any
    to_port     = 22
    cidr_blocks = [var.MYIP] # only allows the inbound traffic from myip(public) but we set from anywhere now
  }
}

#now SG for ec2 instance which is part of beanstalk environment
resource "aws_security_group" "terraform-prod-sg" {
  name        = "terraform-prod-sg"
  description = "security group for beanstalk instance"
  vpc_id      = module.vpc.vpc_id

  egress { #out bound rule
    from_port   = 0
    protocol    = "-1" #from any protocol like ftp,http or any
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #it allows all the outbound traffic anywhere
  }
  #For ingress rule I am gonna give ssh to the beanstalk instance but this is part of a private subnet so we cannot access it from the public n/w . We can access from the bastion host . bastion host part of SG .So we can ssh to the bastion host and then from there we will do SSH which is in beanstalk.

  ingress {
    from_port       = 22
    protocol        = "tcp" #from any protocol like ftp,http or any
    to_port         = 22
    security_groups = [aws_security_group.terraform-bastion-sg.id] #only the private connection from the bastion host to the SG on port 22 here.
  }
}

#now SG for backend service such as RDS,Active MQ,Elasticache
resource "aws_security_group" "terraform-backend-sg" { #error rectified like added one more ingress rule
  name        = "terraform-backend-sg"
  description = "security group for RDS, active MQ, elastic cache"
  vpc_id      = module.vpc.vpc_id

  egress { #ouut bound rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #from any protocol like ftp,http or any
    cidr_blocks = ["0.0.0.0/0"] #it allows all the outbound traffic anywhere
  }

  #beanstalk instance is going to access this backend services
  ingress {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    security_groups = [aws_security_group.terraform-prod-sg.id] # only allows the inbound traffic from ec2 beanstalk instance
  }
  ingress {
    from_port       = 3306
    protocol        = "tcp"
    to_port         = 3306
    security_groups = [aws_security_group.terraform-bastion-sg.id] #allows from bastion host for accessing backend services.
  }
}

#So we are done creating all the SGs resources but these instances RDS,active MQ,elasticache they will be interacting with each other so i want to allow all the traffic from which hold security group ID  so we have a resource group that can help us to do that.
resource "aws_security_group_rule" "sec_group_allow_itself" {
  type      = "ingress" #i am getting ingress rule of backend SG group
  from_port = 0
  #from =0
  to_port                  = 65535 #from 0 to 65535 all ports should allow
  protocol                 = "tcp"
  security_group_id        = aws_security_group.terraform-backend-sg.id # the SG that you want to update and add the rules
  source_security_group_id = aws_security_group.terraform-backend-sg.id #from which SG you want to allow the connection. Again this is same SG id so i am going to allow all the connection to it’s own SG id.
}

#and that’s it , this is the toughest part of this entire stack because it is having so many protocols ingress and egress right but if you have experience with setting up stack manually in aws you can understand this.

#This is the same thing in AWS but we are automating everything and we are maintaining everything through a state file.

