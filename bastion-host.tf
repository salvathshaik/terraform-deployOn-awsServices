resource "aws_instance" "terraform-bastion" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraformkey.key_name
  subnet_id              = module.vpc.public_subnets[0] #our bastion host will create in this first subnet
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.terraform-bastion-sg.id]

  tags = {
    Name    = "terraform-bastion"
    PROJECT = "terraform"
    #and we have one more thing to do provision our RDS instance with the schema use a shell script to this bastion host and that will be have RDS instance endpoints ,username and password and that will be dynamic we have to store it to access the RDS endpoint but terraform already maintains the state of the infrastructure . state should have the RDS endpoint . but for this we need to create a template (terraform template file documentation). There is a ‘templatefile(path,vars	) . path of a template file and you can mentioned the variable RDS endpoint which will be used in template
  }


  provisioner "file" {
    content = templatefile("templates/db-deploy.tmpl", { rds-endpoint = aws_db_instance.terraform-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    #second parameter is for variable passing so for this will create the folder called template in the root directory and move the db-deploy.tmpl to this directory so this is for more manageability.
    #address attribute will give us the endpoint of the instance.
    destination = "/tmp/terraform-dbdeploy.sh" #the destination where we want to push it
  }

  #so we have shell script and we want to execute that
  provisioner "remote-exec" {
    #inline command that execute the below commands
    inline = [
      "chmod +x /tmp/terraform-dbdeploy.sh",
      "sudo /tmp/terraform-dbdeploy.sh",
    ]
  }

  #and of course we also needs to give connection information to access this bastion host to push the file and execute shell script so,
  connection {
    user        = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH) #it will open up the file which is there in root directory and read
    host        = self.public_ip          #since we are executing from our local machine and accessing over the internet we use the public ip of the bastion host
  }

  #so here we are doing two things , not only login to the bastion host but push the script and execute the script to initialize the RDS instance so not only provisioning the bastion host but with script that is initialize the RDS instance so two things and we need to make sure that initializing the RDS server after provisioning the server and bastion host setup happen only after backend services are running.
  depends_on = [aws_db_instance.terraform-rds] #so first it provision the DB instance and then provision the bastion host

}
