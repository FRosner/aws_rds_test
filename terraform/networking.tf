variable "az_number" {
  type = "map"
  # 1 = public subnet
  default = {
    a = 2
    b = 3
    c = 4
    d = 5
    e = 6
    f = 7
  }
}


data "aws_availability_zone" "eu-central-1a" {
  name = "eu-central-1a"
}

data "aws_availability_zone" "eu-central-1b" {
  name = "eu-central-1b"
}

data "aws_availability_zone" "eu-central-1c" {
  name = "eu-central-1c"
}

resource "aws_security_group" "rds_test" {
  name = "rds_test"
  description = "No external traffic allowed"
  vpc_id = "${aws_vpc.rds_test.id}"
}

resource "aws_security_group_rule" "mysql_in" {
  type            = "ingress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.allow_ssh.id}"

  security_group_id = "${aws_security_group.rds_test.id}"
}

resource "aws_vpc" "rds_test" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_db_subnet_group" "rds_test" {
  name       = "rds_test"
  subnet_ids = ["${aws_subnet.rds_test_a.id}", "${aws_subnet.rds_test_b.id}", "${aws_subnet.rds_test_c.id}"]
}

resource "aws_subnet" "rds_test_a" {
  vpc_id     = "${aws_vpc.rds_test.id}"
  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, var.az_number[data.aws_availability_zone.eu-central-1a.name_suffix])}"
  availability_zone = "${data.aws_availability_zone.eu-central-1a.id}"
}

resource "aws_subnet" "rds_test_b" {
  vpc_id     = "${aws_vpc.rds_test.id}"
  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, var.az_number[data.aws_availability_zone.eu-central-1b.name_suffix])}"
  availability_zone = "${data.aws_availability_zone.eu-central-1b.id}"
}

resource "aws_subnet" "rds_test_c" {
  vpc_id     = "${aws_vpc.rds_test.id}"
  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, var.az_number[data.aws_availability_zone.eu-central-1c.name_suffix])}"
  availability_zone = "${data.aws_availability_zone.eu-central-1c.id}"
}

resource "aws_internet_gateway" "rds_test" {
  vpc_id = "${aws_vpc.rds_test.id}"
}

resource "aws_security_group" "rds_test_nat" {
  name = "rds_test_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.rds_test.cidr_block}"]
  }

  vpc_id = "${aws_vpc.rds_test.id}"
}

resource "aws_subnet" "eu-central-1a-public" {
  vpc_id = "${aws_vpc.rds_test.id}"

  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, 1)}"
  availability_zone = "${data.aws_availability_zone.eu-central-1a.id}"
}

resource "aws_eip" "rds_test_nat" {
  instance = "${aws_instance.rds_test_nat.id}"
  depends_on = ["aws_internet_gateway.rds_test"]
  vpc = true
}

resource "aws_route_table" "eu-central-1a-public" {
  vpc_id = "${aws_vpc.rds_test.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rds_test.id}"
  }
}

resource "aws_route_table" "eu-central-private" {
  vpc_id = "${aws_vpc.rds_test.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.rds_test_nat.id}"
  }
}

resource "aws_route_table_association" "eu-central-1a-public" {
  subnet_id = "${aws_subnet.eu-central-1a-public.id}"
  route_table_id = "${aws_route_table.eu-central-1a-public.id}"
}

resource "aws_route_table_association" "eu-central-1a-private" {
  subnet_id = "${aws_subnet.rds_test_a.id}"
  route_table_id = "${aws_route_table.eu-central-private.id}"
}

output "ssh-tunnel" {
  value = "ssh ec2-user@${aws_eip.rds_test_nat.public_ip} -L 2201:${aws_instance.rds_test_sysbench.private_ip}:22"
}

output "ssh" {
  value = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@localhost -p 2201"
}
