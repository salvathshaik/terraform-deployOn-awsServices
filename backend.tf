terraform {
  backend "s3" {
    bucket = "terraform-first-project-state"
    key    = "terraform/backend" #this is the file name we need to store the state in above bucket
    region = "ap-south-1"        #change this
  }
}
