#============================================================================
#ALB
#============================================================================
resource "aws_lb" "alb" {
    name               = "${var.project}-web-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups = [
        aws_security_group.alb_sg.id
    ]
    subnets = [
        aws_subnet.subnet_public1.id,
        aws_subnet.subnet_public2.id
    ]
}

#リスナーの設定
#特定のポートでリクエストを待ち受け →　リクエストに基づいてトラフィックを処理
#ALBのリスナーがHTTPトラフィックを処理する場合は、port:80, HTTPSの場合はport:443でリクエストを待ち受ける
resource "aws_lb_listener" "aws_lb_listener_http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"

#受け取ったリクエストを指定されたターゲットグループへフォワード(転送)する
　default_action {
    type         = "forward"
    target_group = aws_lb_target_group.aws_lb_target_group.arn
 }
}

#ACMで発行したパブリック証明書をALBに適用させる
resource "aws_lb_listener" "aws_lb_listener_https" {
    load_balancer_arn   = aws_lb.alb_arn
    port                = 443
    protocol            = "HTTPS"
    ssl_policy          = "ELBSecurityPolicy-2016-08"
    certificate_arn     = aws_acm_certificate.tokyo_cert.arn 

    default_action = {
        type         = "forward"
        target_group = aws_lb_target_group.aws_lb_target_group.arn
    }
}


#=============================================================================
#ALB Target Group
#=============================================================================
resource "aws_lb_target_group" "aws_lb_target_group" {
    name      = "${var.project}-web-tg"
    port      = 80
    protocpl  = "HTTP"
    vpc_id    = aws_vpc.vpc.id

    tags = {
        Name    = "${var.project}-web-tg"
        Project = var.project 
    }
}


#ターゲットグループに所属させるインスタンスの登録
#1台目のEC2
resource "aws_lb_target_group_attachment" "target_instance_1" {
    target_group_arn  = aws_lb_target_group.aws_lb_target_group.arn
    target_id         = aws_instance.webserver_ec2_1.id
}

#2台目のEC2
resource "aws_lb_target_group_attachment" "target_instance_2" {
    target_group_arn  = aws_lb_target_group.aws_lb_target_group.arn
    target_id         = aws_instance.webserver_ec2_2.id
}