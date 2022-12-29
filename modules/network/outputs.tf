output "security_group" {
    value = aws_security_group.restrict.id
}

output "subnet" {
    value = aws_subnet.external.id
}