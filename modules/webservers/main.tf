data "aws_iam_account_alias" "current" {}

data "aws_ami" "ec2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_iam_policy_document" "ec2_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

##### ASG
resource "aws_autoscaling_group" "dev" {
  name                      = "${var.environment}-${var.service}-asg"
  max_size                  = var.max
  min_size                  = var.min
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.dev.name
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.web_server.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "dev" {
  name_prefix          = "${var.environment}-${var.service}-web-config"
  image_id             = data.aws_ami.ec2.id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.security_group.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.id
  enable_monitoring    = true

  user_data = templatefile("${path.module}/lib/init.sh.tpl",
    {
      service_name     = var.service
      environment      = var.environment
      aws_account_name = data.aws_iam_account_alias.current.account_alias
  })

  root_block_device {
    encrypted = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

##### TG
resource "aws_lb_target_group" "web_server" {
  name        = "${var.environment}-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    interval            = 20
    path                = "/"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-${var.service}-http-target-group"
  }
}


resource "aws_lb_listener_rule" "external_forwarder_rule" {
  listener_arn = var.external_lb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
  priority = 1
}

##### SG
resource "aws_security_group" "security_group" {
  name   = "${var.environment}-${var.service}-instance-sg"
  vpc_id = var.vpc_id
  
  tags = {
    Name = "web-security-group"
  }
}

resource "aws_security_group_rule" "external_port" {
  description              = "ingress http"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.security_group.id
  to_port                  = 80
  type                     = "ingress"
  source_security_group_id = var.external_lb_security_group_id
}

# egress all
resource "aws_security_group_rule" "egress_all" {
  description       = "Egress all"
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}


# IAM role
resource "aws_iam_role" "iam_role" {
  name               = "${var.environment}-${var.service}"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_trust.json
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.environment}-${var.service}"
  role = aws_iam_role.iam_role.name
}