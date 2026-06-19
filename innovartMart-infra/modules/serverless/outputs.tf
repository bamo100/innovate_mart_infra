output "bucket_name" {
  description = "The name of the assets bucket"
  value       = aws_s3_bucket.assets.id
}
