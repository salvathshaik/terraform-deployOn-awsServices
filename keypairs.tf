resource "aws_key_pair" "terraformkey" {
  key_name   = "terraformkey"         #key will get created with this name in aws account
  public_key = file(var.PUB_KEY_PATH) #for pub keyy we are not giving the content we are giving function file to read our local pub file use to create private key in aws
}
