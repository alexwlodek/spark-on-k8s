variable "env" {
  description = "Environment name."
  type        = string
}

variable "bucket_name" {
  description = "Optional explicit bucket name. If empty, a default name will be constructed."
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket."
  type        = bool
  default     = false
}

variable "lifecycle_expiration_days" {
  description = "Number of days after which objects are expired."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
