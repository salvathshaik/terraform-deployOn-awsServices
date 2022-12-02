resource "aws_elastic_beanstalk_environment" "terraform-bean-env-prod" {
  name                = "terraform-bean-env-prod"
  application         = aws_elastic_beanstalk_application.terraform-bean-app-prod.name #rectified
  solution_stack_name = "64bit Amazon Linux v4.1.1 running Tomcat 8.5 Corretto 11"
  cname_prefix        = "terraform-bean-prod-domain" #check this again i have checked.

  setting {
    namespace = "aws:ec2:vpc" #i want to put this into vpc that i have created
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }

  #so like that i can put all settings that i want it for beanstalk environment
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting { # i want to put all the instances in the private subnets
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]) #join will join the list into string, so you can check all the terraform functions in registry seach
  }

  setting { #and above instances wiil be in private subnet but load balancer will be in public subnet
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]])
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.terraformkey.key_name
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = "Any 3" # i want to launch in any 3 subnets
  }

  #autoscaling settings
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "8"
  }

  #now lets create settings for environment for beanstalk
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "environment"
    value     = "prod"
  }

  setting { #settings  for the logs
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LOGGING_APPENDER"
    value     = "GRAYLOG"
  }

  setting { #settings for health monitoring
    namespace = "aws:elasticbeanstalk:healthreporting:environment"
    name      = "SystemType"
    value     = "enhanced" #you can change it to “basic”
  }

  #autoscale settings as in rolling update stratagy
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  #if it is healthy then go for other batch while rolling
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "health"
  }

  setting { #rolling update size
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = "1"
  }


  setting { #
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone" #it is like load balancer for multiple cross zones
    value     = "true"
  }

  setting { #this is for stickiness
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = "true"
  }


  setting { ##size you can give it as percentage if you want
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Fixed"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "1"
  }

  setting { #deployment policy as rolling
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.terraform-prod-sg.id #chck this  #which SG you want our ec2 instance want to be
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.terraform-bean-elb-sg.id #chck
  }

  # so elb SG create and then beanstalk sg create so terraform first create this dependency thing and then go for above all environments
  depends_on = [aws_security_group.terraform-bean-elb-sg, aws_security_group.terraform-prod-sg]
}
