output "dev_user_arn" {
  description = "ARN of the dev IAM user"
  value       = aws_iam_user.dev.arn
}

output "dev_access_key" {
  description = "Access key for the dev user"
  value       = aws_iam_access_key.dev.id
  sensitive   = true
}

output "dev_secret_key" {
  description = "Secret key for the dev user"
  value       = aws_iam_access_key.dev.secret
  sensitive   = true
}

output "dev_password" {
  description = "Console password for the dev user"
  value       = aws_iam_user_login_profile.dev.password
  sensitive   = true
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
