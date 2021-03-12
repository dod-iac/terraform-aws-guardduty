<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an AWS GuardDuty Detector, KMS Key for encrypting exports to S3, and CloudWatch rule to watch for findings.

```hcl
module "guardduty" {
  source = "dod-iac/guardduty/aws"

  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

You can customize the finding publishing frequency.

```hcl
module "guardduty" {
  source = "dod-iac/guardduty/aws"

  enable = true
  finding_publishing_frequency = "SIX_HOURS"
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

You can exports GuardDuty findings to a S3 bucket using the s3\_bucket\_name variable.

```hcl
module "guardduty" {
  source = "dod-iac/guardduty/aws"

  enable = true
  s3_bucket_name = module.logs.aws_logs_bucket
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) |
| [aws_cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) |
| [aws_guardduty_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) |
| [aws_guardduty_publishing_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_publishing_destination) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) |
| [aws_s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable | Enable monitoring and feedback reporting.  Setting to false is equivalent to "suspending" GuardDuty. | `bool` | `true` | no |
| finding\_publishing\_frequency | Specifies the frequency of notifications sent for subsequent finding occurrences.  If the detector is a GuardDuty member account, the value is determined by the GuardDuty master account and cannot be modified, otherwise defaults to SIX\_HOURS.  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.  Valid values for standalone and master accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS. | `string` | `"FIFTEEN_MINUTES"` | no |
| kms\_alias\_name | The display name of the alias of the KMS key used to encrypt exports to S3. The name must start with the word "alias" followed by a forward slash (alias/). | `string` | `"alias/guardduty"` | no |
| s3\_bucket\_name | The name of the S3 bucket that receives findings from GuardDuty.  If blank, then GuardDuty does not export findings to S3. | `string` | `""` | no |
| s3\_bucket\_prefix | The prefix for where findings from GuardDuty are stored in the S3 bucket.  Should start with "/" if defined.  GuardDuty will build the full destination ARN using this format: S3BUCKETARNS3BUCKETPREFIX/AWSLogs/ACCOUNTID/GuardDuty/REGION. | `string` | `"/guardduty"` | no |
| sns\_topic\_arn | The ARN of an SNS Topic to send events to. | `string` | `""` | no |
| tags | Tags to apply to the AWS Resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_event\_rule\_name | Name of the CloudWatch rule that watches for AWS GuardDuty findings. |
| aws\_guardduty\_detector\_id | The ID of the GuardDuty detector. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
