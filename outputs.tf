output "id" {
  description = "ID of the instance."
  value       = aws_instance.this.id
}

output "arn" {
  description = "ARN of the instance."
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IPv4 address of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IPv4 address of the instance, if assigned."
  value       = aws_instance.this.public_ip
}

output "availability_zone" {
  description = "Availability zone the instance runs in."
  value       = aws_instance.this.availability_zone
}
