# Create service-linked role for Auto Scaling
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# IAM policy document for the Auto Scaling group
data "aws_iam_policy_document" "asg_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }
  }
}
resource "aws_iam_service_linked_role" "asg" {
  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix    = "${var.project_name}-ASG"
}
resource "aws_iam_role" "asg_role" {
  name               = "${var.project_name}-ASG-Role"
  assume_role_policy = data.aws_iam_policy_document.asg_assume_role_policy.json
}
# terraform aws launch template
resource "aws_launch_template" "ec2_asg" {
  name                  = "my-launch-template"
  image_id              = data.aws_ami.amazon_linux_2.id
  instance_type         = "t2.micro"
  user_data = base64encode(templatefile("userdata.sh", { request_id = "REQ000129834", name = "John" }))
  vpc_security_group_ids = [var.alb_security_group_id]
  lifecycle {
    create_before_destroy = true
  }
}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "asg-tf" {
  name                 = "${var.project_name}-ASG"
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  force_delete         = true
  depends_on           = [var.application_load_balancer, aws_iam_service_linked_role.asg, aws_iam_role.asg_role]
  target_group_arns    = [var.alb_target_group_arn]
  health_check_type    = "EC2"
  launch_template {
    id      = aws_launch_template.ec2_asg.id
    version = aws_launch_template.ec2_asg.latest_version
  }
  vpc_zone_identifier  = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  tag {
    key                 = "Name"
    value               = "${var.project_name}-ASG"
    propagate_at_launch = true
  }
}