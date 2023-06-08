# Launch template

resource "aws_launch_template" "machine_image_type" {
  name_prefix            = "terraform"
  image_id               = var.used_image
  instance_type          = var.instance_type
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
   }
  tags = {
      Name =  "launch_configuration_template"
  }
   
  vpc_security_group_ids = [aws_security_group.allow_sec1.id]

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    EOF
  )
}

############################################
# Auto scaling group files
############################################

# Auto scaling group creation

resource "aws_autoscaling_group" "my_autoscaling_group" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.subnet_3.id, aws_subnet.subnet_4.id]
  target_group_arns = [ aws_lb_target_group.alb-target.arn ]
  launch_template {
    id      = aws_launch_template.machine_image_type.id
    version = "$Latest"
  }
}

# Auto Scaling Policy

resource "aws_autoscaling_policy" "the_policy" {
  name                   = "autoscaling_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.name
}

# Cloudwatch alarm settings

resource "aws_cloudwatch_metric_alarm" "my_alarm" {
  alarm_name                = "terraform-test-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "Cpu utilization threshold overload - adding another instance"
  alarm_actions = [aws_autoscaling_policy.the_policy.arn]
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.my_autoscaling_group.name
  }
}

# Policy attachment for auto scaling group

resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.id
  lb_target_group_arn = aws_lb_target_group.alb-target.arn
}
