output "public_ip" {
    value       = aws_instance.my_app_server.public_ip
    description = "The public IP address of my web server"
}

output "all_infos" {
    value       = aws_instance.my_app_server
    description = "The public IP address of my web server"
}

output "aws_default_vpc_id" {
    value       = data.aws_vpc.default.id
    description = "The id of the default AWS VPC"
}