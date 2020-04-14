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
  tags                    = var.kms_key_tags
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
}
