# Terraform config. for Cloud Resume Projcect.

#1. Create an S3 Bucket to host the resume website.
resource "aws_s3_bucket" "resume" {
  bucket = var.bucket_name
}

# Enable Public Access Block for the S3 Bucket.
resource "aws_s3_bucket_public_access_block" "resume" {
  bucket = aws_s3_bucket.resume.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure the S3 Bucket for static website hosting.
resource "aws_s3_bucket_website_configuration" "resume" {
  bucket = aws_s3_bucket.resume.id

  index_document {
    suffix = "index.html"
  }
}

# Upload the index.html file to the S3 Bucket.
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.resume.id
  key          = "index.html"
  source       = "${path.module}/frontend/index.html"
  content_type = "text/html"

  etag = filemd5("${path.module}/frontend/index.html")
}

# Create Bucket Policy to allow public read access to the S3 Bucket.
resource "aws_s3_bucket_policy" "resume" {
  bucket = aws_s3_bucket.resume.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.resume.arn}/*"
    }]
  })
}

# 2. Create a CloudFront Distribution to serve the resume website. 
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "resume" {
  enabled = true
  comment = "Cloud Resume Challenge Distribution"

  origin {
    domain_name = aws_s3_bucket_website_configuration.resume.website_endpoint
    origin_id   = "s3-resume-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-resume-origin"

    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  default_root_object = "index.html"

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


#3. Configuring DynamoDB Table to get store visitors count.
resource "aws_dynamodb_table" "counter" {
  name         = "visitor-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

#4. Create an IAM Role for Lambda Function to access DynamoDB Table
resource "aws_iam_role" "lambda_role" {
  name = "terraform-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.counter.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

#5. Create a Lambda Function to get vistors_count.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/visitor_counter.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "counter" {
  function_name = "visitorCounterTerraform"
  runtime       = "python3.12"
  handler       = "visitor_counter.lambda_handler"
  role          = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

#6. Create an API Gateway to trigger the Lambda Function.(HTTP API)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "visitor-counter-api-terraform"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.counter.invoke_arn
}

resource "aws_apigatewayv2_route" "count" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}