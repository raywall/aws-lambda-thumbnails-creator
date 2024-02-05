####
# PROJECT
####
variable "aws_region" {
    type = string
    description = "Region where the project will be deployed"
}


####
# S3 BUCKET
####
variable "s3_bucket_name" {
    type = string
    description = "Name of the s3 bucket"
}


####
# LAMBDA FUNCTION
####
variable "lambda_function_name" {
    type = string
    description = "Name of the lambda function"
}

variable "lambda_function_runtime" {
    type = string
    description = "Runtime of the lambda function"
    default = "provided.al2023"
}

variable "lambda_function_handler" {
    type = string
    description = "Handler of the lambda function"
    default = "bootstrap"
}

variable "lambda_function_role_name" {
    type = string
    description = "IAM role name of the lambda function"
}

variable "lambda_function_policy_name" {
    type = string
    description = "IAM policy name of the lambda function"
}

variable "lambda_function_package_extension" {
    type = string
    description = "Package extension of the lambda function"
    default = "zip"
}

variable "lambda_function_package_path" {
    type = string
    description = "Package path of the lambda function"
    default = "./dist/package.zip"
}

variable "lambda_function_source_code" {
    type = string
    description = "Source code of the lambda function"
    default = "./dist"
}

variable "lambda_function_environment_variables" {
    type = map(string)
    description = "Environment variables of the lambda function"
    default = {}
}

variable "lambda_function_architectures" {
    type = list(string)
    description = "Architectures of the lambda function"
    default = [ "arm64" ]
}
