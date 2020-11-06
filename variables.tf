variable "enable" {
  type        = bool
  description = "Enable monitoring and feedback reporting.  Setting to false is equivalent to \"suspending\" GuardDuty."
  default     = true
}

variable "finding_publishing_frequency" {
  type        = string
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences.  If the detector is a GuardDuty member account, the value is determined by the GuardDuty master account and cannot be modified, otherwise defaults to SIX_HOURS.  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.  Valid values for standalone and master accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS. "
  default     = "FIFTEEN_MINUTES"
}

variable "kms_alias_name" {
  type        = string
  description = "The display name of the alias of the KMS key used to encrypt exports to S3. The name must start with the word \"alias\" followed by a forward slash (alias/)."
  default     = "alias/guardduty"
}

variable "kms_key_tags" {
  type        = map(string)
  description = "Tags to apply to the AWS KMS Key used to encrypt exports to S3."
  default     = {}
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket that receives findings from GuardDuty.  If blank, then GuardDuty does not export findings to S3."
  default     = ""
}

variable "s3_bucket_prefix" {
  type        = string
  description = "The prefix for where findings from GuardDuty are stored in the S3 bucket.  Should start with \"/\" if defined.  GuardDuty will build the full destination ARN using this format: <s3_bucket_arn><s3_bucket_prefix>/AWSLogs/<account_id>/GuardDuty/<region>."
  default     = "/guardduty"
}
