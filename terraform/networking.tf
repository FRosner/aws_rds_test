variable "az_number" {
  type = "map"
  # Assign a number to each AZ letter used in our configuration
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }
}


data "aws_availability_zone" "a" {
  name = "eu-central-1a"
}

data "aws_availability_zone" "b" {
  name = "eu-central-1b"
}

data "aws_availability_zone" "c" {
  name = "eu-central-1c"
}

resource "aws_security_group" "rds_test" {
  name = "rds_test"
  description = "No external traffic allowed"
  vpc_id = "${aws_vpc.rds_test.id}"
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
  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, var.az_number[data.aws_availability_zone.a.name_suffix])}"
  availability_zone = "${data.aws_availability_zone.a.id}"
}

resource "aws_subnet" "rds_test_b" {
  vpc_id     = "${aws_vpc.rds_test.id}"
  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, var.az_number[data.aws_availability_zone.b.name_suffix])}"
  availability_zone = "${data.aws_availability_zone.b.id}"
}

resource "aws_subnet" "rds_test_c" {
  vpc_id     = "${aws_vpc.rds_test.id}"
  cidr_block = "${cidrsubnet(aws_vpc.rds_test.cidr_block, 4, var.az_number[data.aws_availability_zone.c.name_suffix])}"
  availability_zone = "${data.aws_availability_zone.c.id}"
}