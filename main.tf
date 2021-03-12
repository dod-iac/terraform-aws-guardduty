/**
 * ## Usage
 *
 * Creates an AWS GuardDuty Detector, KMS Key for encrypting exports to S3, and CloudWatch rule to watch for findings.
 *
 * ```hcl
 * module "guardduty" {
 *   source = "dod-iac/guardduty/aws"
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * You can customize the finding publishing frequency.
 *
 * ```hcl
 * module "guardduty" {
 *   source = "dod-iac/guardduty/aws"
 *
 *   enable = true
 *   finding_publishing_frequency = "SIX_HOURS"
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * You can exports GuardDuty findings to a S3 bucket using the s3_bucket_name variable.
 *
 * ```hcl
 * module "guardduty" {
 *   source = "dod-iac/guardduty/aws"
 *
 *   enable = true
 *   s3_bucket_name = module.logs.aws_logs_bucket
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 is not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "key_policy" {
  policy_id = "key-consolepolicy"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "Allow GuardDuty to use the key"
    actions = [
      "kms:GenerateDataKey"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "guardduty.amazonaws.com"
      ]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "guardduty" {
  description             = "Key used to encrypt GuardDuty findings."
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.key_policy.json
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "guardduty" {
  name          = var.kms_alias_name
  target_key_id = aws_kms_key.guardduty.key_id
}

resource "aws_guardduty_detector" "main" {
  enable                       = var.enable
  finding_publishing_frequency = var.finding_publishing_frequency
  depends_on = [
    aws_kms_key.guardduty,
    aws_kms_alias.guardduty
  ]
}

data "aws_s3_bucket" "main" {
  count  = length(var.s3_bucket_name) > 0 ? 1 : 0
  bucket = var.s3_bucket_name
}

# GuardDuty expects a folder to exist, otherwise it throws an error.
resource "aws_s3_bucket_object" "guardduty" {
  count  = length(var.s3_bucket_name) > 0 && length(var.s3_bucket_prefix) > 0 ? 1 : 0
  bucket = data.aws_s3_bucket.main.0.id
  acl    = "private"
  key = var.s3_bucket_prefix == "/" ? "/" : format("%s/", (
    substr(var.s3_bucket_prefix, 0, 1) == "/" ?
    substr(var.s3_bucket_prefix, 1, length(var.s3_bucket_prefix)) :
    var.s3_bucket_prefix
  ))
  source = "/dev/null"
}

resource "aws_guardduty_publishing_destination" "main" {
  count           = length(var.s3_bucket_name) > 0 ? 1 : 0
  detector_id     = aws_guardduty_detector.main.id
  destination_arn = format("%s%s", data.aws_s3_bucket.main.0.arn, (length(var.s3_bucket_prefix) > 0 ? var.s3_bucket_prefix : "/"))
  kms_key_arn     = aws_kms_key.guardduty.arn
  depends_on = [
    aws_s3_bucket_object.guardduty
  ]
}

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name          = "guardduty-finding-events"
  description   = "AWS GuardDuty event findings"
  event_pattern = <<EOF
  {
    "detail-type": [
      "GuardDuty Finding"
    ],
    "source": [
      "aws.guardduty"
    ]
  }
  EOF

  tags = var.tags
}

# More details about the response syntax can be found here:
# https://docs.aws.amazon.com/guardduty/latest/ug/get-findings.html#get-findings-response-syntax
resource "aws_cloudwatch_event_target" "guardduty_findings" {
  count = length(var.sns_topic_arn) ? 1 : 0

  rule = aws_cloudwatch_event_rule.guardduty_findings.name

  arn = var.sns_topic_arn

  input_transformer {
    input_paths = {
      account     = "$.detail.accountId"
      title       = "$.detail.title"
      description = "$.detail.description"
      eventTime   = "$.detail.service.eventFirstSeen"
      region      = "$.detail.region"
    }
    input_template = "\"GuardDuty finding in account <account> <region> first seen at <eventTime>: <title> <description>\""
  }
}
