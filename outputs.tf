output "aws_cloudwatch_event_rule_name" {
  description = "Name of the CloudWatch rule that watches for AWS GuardDuty findings."
  value       = aws_cloudwatch_event_rule.guardduty_findings.name
}
