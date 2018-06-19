variable "apply_immediately" {
  default = "false"
  description = "Whether to deploy changes to the database immediately (true) or at the next maintenance window (false)."
}

resource "aws_db_instance" "rds_test_mysql" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "rds_test_mysql"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.rds_test.name}"
  vpc_security_group_ids = ["${aws_security_group.rds_test_mysql.id}"]
  apply_immediately = "${var.apply_immediately}"
  final_snapshot_identifier = "rds-test-mysql-final"
}