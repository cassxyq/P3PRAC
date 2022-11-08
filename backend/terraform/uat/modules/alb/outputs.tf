output "alb-tg" {
    value = aws_lb_target_group.app
    //.arn
}

output "alb-sg" {
    value = aws_security_group.lb-sg.id
}