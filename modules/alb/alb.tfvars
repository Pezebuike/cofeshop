project_name="${var.project_name}-alb"
vpc_id=aws_vpc.infra.id
public_subnet_az1_id=aws_subnet.public_subnet_az1.id
public_subnet_az2_id=aws_subnet.public_subnet_az2.id
alb_security_group_id=aws_security_group.alb_security_group.id