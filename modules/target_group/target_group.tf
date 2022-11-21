resource "aws_alb_target_group" "target_group" {
  name     = var.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold = 3
    timeout           = 2
    path              = "/index.html"
    matcher           = "200"
    interval          = 5
  }
}

resource "aws_alb_target_group_attachment" "tg_attachment" {
  count            = length(var.ec2_ids)
  target_group_arn = aws_alb_target_group.target_group.arn
  target_id        = var.ec2_ids[count.index]
}