####
# PROJECT
####
aws_region = "us-east-1"


####
# APPLICATION
####
lambda_function_source_code = "../dist/."
s3_bucket_name = "building-strong-serverless-application"


####
# LAMBDA FUNCTION
####
lambda_function_name = "thumbnails-creator-function"
lambda_function_role_name = "thumbnails-creator-function-role"
lambda_function_policy_name = "thumbnails-creator-function-policy"
lambda_function_environment_variables = {
    REGION = "us-east-1",
    ENVIRONMENT = "dev"
}