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
| terraform | >= 0.12.0 |
| aws | >= 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable | Enable monitoring and feedback reporting.  Setting to false is equivalent to "suspending" GuardDuty. | `bool` | `true` | no |
| finding\_publishing\_frequency | Specifies the frequency of notifications sent for subsequent finding occurrences.  If the detector is a GuardDuty member account, the value is determined by the GuardDuty master account and cannot be modified, otherwise defaults to SIX\_HOURS.  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.  Valid values for standalone and master accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS. | `string` | `"FIFTEEN_MINUTES"` | no |
| kms\_alias\_name | The display name of the alias of the KMS key used to encrypt exports to S3. The name must start with the word "alias" followed by a forward slash (alias/). | `string` | `"alias/guardduty"` | no |
| kms\_key\_tags | Tags to apply to the AWS KMS Key used to encrypt exports to S3. | `map(string)` | `{}` | no |
| s3\_bucket\_name | The name of the S3 bucket that receives findings from GuardDuty.  If blank, then GuardDuty does not export findings to S3. | `string` | `""` | no |
| s3\_bucket\_prefix | The prefix for where findings from GuardDuty are stored in the S3 bucket.  Should start with "/" if defined.  GuardDuty will build the full destination ARN using this format: <s3\_bucket\_arn><s3\_bucket\_prefix>/AWSLogs/<account\_id>/GuardDuty/<region>. | `string` | `"/guardduty"` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_event\_rule\_name | Name of the CloudWatch rule that watches for AWS GuardDuty findings. |
| aws\_guardduty\_detector\_id | The ID of the GuardDuty detector. |

