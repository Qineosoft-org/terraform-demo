resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  instance_type = var.instance_type
  key_name      = var.ami_key_pair_name

  tags = {
    name = "${var.environment}-server"

  }
}
