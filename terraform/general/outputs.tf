output "s3_bucket_name" {
  value       = aws_s3_bucket.shared_assets.id
  description = "Name of the shared S3 bucket"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.shared_assets.arn
  description = "ARN of the shared S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.shared_config.name
  description = "Name of the shared DynamoDB table"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.shared_config.arn
  description = "ARN of the shared DynamoDB table"
}

output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.main.id
  description = "ID of the Cognito User Pool"
}

output "cognito_client_id" {
  value       = aws_cognito_user_pool_client.web_client.id
  description = "ID of the Cognito User Pool Client"
}

output "cognito_issuer_url" {
  value       = "https://${aws_cognito_user_pool.main.endpoint}"
  description = "Issuer URL for the Cognito User Pool"
}
