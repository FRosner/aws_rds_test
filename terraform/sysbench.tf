resource "aws_instance" "rds_test_sysbench" {
  ami           = "${data.aws_ami.rds_test_sysbench.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  subnet_id = "${aws_subnet.rds_test_a.id}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  vpc_id = "${aws_vpc.rds_test.id}"
}

resource "aws_security_group_rule" "mysql_out" {
  type            = "egress"
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.rds_test.id}"

  security_group_id = "${aws_security_group.allow_ssh.id}"
}

resource "aws_security_group_rule" "sysbench_ssh_in" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_ssh.id}"
}

data "aws_ami" "rds_test_sysbench" {
  most_recent      = true
  name_regex = "rds_test_sysbench.*"
  owners     = ["195499643157"]
}

output "sysbench_cmd_1" {
  value = "mysql -u${aws_db_instance.rds_test_mysql.username} -p${aws_db_instance.rds_test_mysql.password} -h${aws_db_instance.rds_test_mysql.address} -P${aws_db_instance.rds_test_mysql.port} -e 'create database sbtest;'"
}

output "sysbench_cmd_2" {
  value = "sysbench --test=oltp --oltp-table-size=250 --mysql-user=${aws_db_instance.rds_test_mysql.username} --mysql-password=${aws_db_instance.rds_test_mysql.password} --db-driver=mysql --mysql-host=${aws_db_instance.rds_test_mysql.address} --mysql-port=${aws_db_instance.rds_test_mysql.port} prepare"
}

output "sysbench_cmd_3" {
  value = "sysbench --db-driver=mysql --num-threads=4 --max-requests=10 --test=oltp --mysql-table-engine=innodb --oltp-table-size=250 --max-time=300 --mysql-engine-trx=yes --mysql-user=${aws_db_instance.rds_test_mysql.username} --mysql-password=${aws_db_instance.rds_test_mysql.password} --mysql-host=${aws_db_instance.rds_test_mysql.address} --mysql-port=${aws_db_instance.rds_test_mysql.port} run"
}