data "aws_ami" "nat" {
  most_recent      = true
  name_regex = "amzn-ami-vpc-nat-hvm-2018.03.0.20180508-x86_64-ebs"
  owners     = ["137112412989"]
}

resource "aws_instance" "rds_test_nat" {
  ami = "${data.aws_ami.nat.id}" # this is a special ami preconfigured to do NAT (https://gist.github.com/mdfGit/48721c7cc0a9f18f27e7)
  availability_zone = "${data.aws_availability_zone.eu-central-1a.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.rds_test_nat.id}"]
  subnet_id = "${aws_subnet.eu-central-1a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false
}