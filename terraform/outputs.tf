output "api_url" {
  description = "API Gateway base URL"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.resume.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (used for cache invalidation)"
  value       = aws_cloudfront_distribution.resume.id
}

output "s3_bucket_name" {
  description = "S3 bucket hosting the resume frontend"
  value       = aws_s3_bucket.resume.bucket
}