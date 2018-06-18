resource "aws_instance" "rds_test_sysbench" {
  ami           = "${data.aws_ami.rds_test_sysbench.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  subnet_id = "${aws_subnet.rds_test_a.id}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  # SSH access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.rds_test.id}"
}

data "aws_ami" "rds_test_sysbench" {
  most_recent      = true
  name_regex = "rds_test_sysbench"
  owners     = ["195499643157"]
}
