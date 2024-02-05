# IAM Role and policy
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_lambda_role" {
    name                    = var.lambda_function_role_name
    assume_role_policy      = data.aws_iam_policy_document.this.json
    force_detach_policies   = true

    inline_policy {
        name = var.lambda_function_policy_name

        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Sid      = "CreateThumbnails"
                    Action   = [ "s3:DeleteObject", "s3:PutObject" ]
                    Effect   = "Allow"
                    Resource = "arn:aws:s3:::${var.s3_bucket_name}/thumbs/*"
                },
                {
                    Sid      = "ReadAll"
                    Action   = [ "s3:GetObject" ]
                    Effect   = "Allow"
                    Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
                },
                {
                    Sid      = "ListAll"
                    Action   = [ "s3:ListBucket" ]
                    Effect   = "Allow"
                    Resource = "arn:aws:s3:::${var.s3_bucket_name}"
                },
            ]
        })
    }
}

# S3 Bucket
resource "aws_s3_bucket" "this" {
    bucket = var.s3_bucket_name
}

# Lambda Function
data "archive_file" "this" {
    type        = var.lambda_function_package_extension
    source_dir  = var.lambda_function_source_code
    output_path = var.lambda_function_package_path
}

resource "aws_lambda_function" "this" {
    filename         = var.lambda_function_package_path
    function_name    = var.lambda_function_name
    role             = aws_iam_role.iam_lambda_role.arn
    handler          = var.lambda_function_handler
    source_code_hash = data.archive_file.this.output_base64sha256
    architectures    = var.lambda_function_architectures
    runtime          = var.lambda_function_runtime

    environment {
        variables = var.lambda_function_environment_variables
    }
}

resource "aws_lambda_permission" "this" {
    statement_id  = "AllowExecutionFromS3Bucket"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.this.function_name
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.this.arn

    depends_on = [ aws_lambda_function.this, aws_s3_bucket.this ]
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "this" {
    bucket = aws_s3_bucket.this.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.this.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "imagens/"
        filter_suffix       = ".jpg"
    }

    depends_on = [ aws_lambda_permission.this ]
}