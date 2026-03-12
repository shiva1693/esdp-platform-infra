output "bucket_id" {
    description = "ID of the S3 bucket for Terraform state"
    value = aws_s3_bucket.tf_state_bucket.id
}