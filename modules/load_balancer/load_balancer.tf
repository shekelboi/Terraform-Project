resource "aws_lb" "load_balancer" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnet_ids
}

resource "aws_lb_listener" "redirect_http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_acm_certificate" "tanuljindonezul_acm" {
  domain = "*.tanuljindonezul.hu"
}

resource "aws_lb_listener" "forward_traffic" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.tanuljindonezul_acm.arn

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
}

data "aws_route53_zone" "tanuljindonezul" {
  name = "tanuljindonezul.hu"
}

resource "aws_route53_record" "alb_cname" {
  zone_id = data.aws_route53_zone.tanuljindonezul.id
  name    = "project"
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.load_balancer.dns_name]
}
