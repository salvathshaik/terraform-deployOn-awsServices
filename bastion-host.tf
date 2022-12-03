resource "aws_instance" "terraform-bastion" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraformkey.key_name
  subnet_id              = module.vpc.public_subnets[0] #our bastion host will create in this first subnet
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.terraform-bastion-sg.id]

  tags ={
    Name    = "terraform-bastion"
    PROJECT = "terraform"
    #and we have one more thing to do provision our RDS instance with the schema use a shell script to this bastion host and that will be have RDS instance endpoints ,username and password and that will be dynamic we have to store it to access the RDS endpoint but terraform already maintains the state of the infrastructure . state should have the RDS endpoint . but for this we need to create a template (terraform template file documentation). There is a ‘templatefile(path,vars	) . path of a template file and you can mentioned the variable RDS endpoint which will be used in template
  }
}
