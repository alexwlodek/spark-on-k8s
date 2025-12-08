variable "repository_name" {
  type        = string
  description = "Name of the ECR repository (without account/region prefix)"
}

variable "scan_on_push" {
  type        = bool
  description = "Enable image scanning on push"
  default     = true
}

variable "encryption_type" {
  type        = string
  description = "ECR encryption type: KMS or AES256"
  default     = "AES256"
}

variable "kms_key_arn" {
  type        = string
  description = "Optional KMS key ARN for ECR encryption. Required if encryption_type=KMS and you don't want to use AWS managed key."
  default     = ""
}

variable "lifecycle_policy_enabled" {
  type        = bool
  description = "Whether to attach lifecycle policy to ECR repository"
  default     = true
}

variable "lifecycle_policy_days" {
  type        = number
  description = "Number of days to keep untagged images (for lifecycle policy)"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to ECR repository"
  default     = {}
}
