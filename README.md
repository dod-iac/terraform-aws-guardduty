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

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable | Enable monitoring and feedback reporting.  Setting to false is equivalent to "suspending" GuardDuty. | `bool` | `true` | no |
| finding\_publishing\_frequency | Specifies the frequency of notifications sent for subsequent finding occurrences.  If the detector is a GuardDuty member account, the value is determined by the GuardDuty master account and cannot be modified, otherwise defaults to SIX\_HOURS.  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.  Valid values for standalone and master accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS. | `string` | `"FIFTEEN_MINUTES"` | no |
| kms\_alias\_name | The display name of the alias of the KMS key used to encrypt exports to S3. The name must start with the word "alias" followed by a forward slash (alias/). | `string` | `"alias/guardduty"` | no |
| kms\_key\_tags | Tags to apply to the AWS KMS Key used to encrypt exports to S3. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_event\_rule\_name | Name of the CloudWatch rule that watches for AWS GuardDuty findings. |

