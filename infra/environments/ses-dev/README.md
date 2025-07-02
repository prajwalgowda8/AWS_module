
# SES Development Environment

This environment deploys the sc-ses-emailservice-demo SES infrastructure for email services with comprehensive monitoring and compliance features.

## Prerequisites

Before deploying this environment, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **SES permissions** for creating and managing email services
4. **Email verification** access for the specified email address

## SES Configuration

### Email Identity
- **Email Address**: cicloudforteaimlnotifications@unisys.com
- **Verification**: Required before sending emails
- **Purpose**: Unisys CI/CD and team notifications

### Configuration Set
- **Name**: sc-ses-emailservice-demo-config-set
- **TLS Policy**: Required (enforced encryption)
- **Reputation Metrics**: Enabled
- **Sending**: Enabled

### Event Destinations
- **CloudWatch**: Enabled for all email events
- **SNS**: Disabled (using CloudWatch instead)
- **Kinesis**: Disabled

## Infrastructure Components

### Email Templates
1. **Welcome Email**: User onboarding template
2. **Notification Email**: General notification template
3. **Alert Email**: Critical alert template with styling

### SNS Topics
- **Bounce Notifications**: Handles email bounces
- **Complaint Notifications**: Handles spam complaints
- **SES Alarms**: CloudWatch alarm notifications

### CloudWatch Monitoring
- **Log Group**: `/aws/ses/sc-ses-emailservice-demo` (30-day retention)
- **Sending Quota Alarm**: 80% threshold
- **Bounce Rate Alarm**: 5% threshold
- **Complaint Rate Alarm**: 0.1% threshold

### IAM Role
- **SES Sending Role**: For applications to send emails
- **Permissions**: SendEmail, SendRawEmail, SendTemplatedEmail

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Post-Deployment

After successful deployment:

1. **Verify email address**:
   ```bash
   aws ses verify-email-identity --email-address cicloudforteaimlnotifications@unisys.com
   ```

2. **Check verification status**:
   ```bash
   aws ses get-identity-verification-attributes --identities cicloudforteaimlnotifications@unisys.com
   ```

3. **Test email sending**:
   ```bash
   aws ses send-email \
     --source cicloudforteaimlnotifications@unisys.com \
     --destination ToAddresses=test@example.com \
     --message Subject={Data="Test Email",Charset=utf8},Body={Text={Data="This is a test email",Charset=utf8}}
   ```

4. **Check sending statistics**:
   ```bash
   aws ses get-send-statistics
   ```

## Email Templates Usage

### Welcome Email Template
```bash
aws ses send-templated-email \
  --source cicloudforteaimlnotifications@unisys.com \
  --destination ToAddresses=user@example.com \
  --template welcome_email \
  --template-data '{"company_name":"Unisys"}'
```

### Notification Email Template
```bash
aws ses send-templated-email \
  --source cicloudforteaimlnotifications@unisys.com \
  --destination ToAddresses=team@example.com \
  --template notification_email \
  --template-data '{"notification_type":"Deployment","subject":"Production Release","message":"The production deployment has completed successfully."}'
```

### Alert Email Template
```bash
aws ses send-templated-email \
  --source cicloudforteaimlnotifications@unisys.com \
  --destination ToAddresses=oncall@example.com \
  --template alert_email \
  --template-data '{"alert_type":"System Down","alert_message":"Critical system failure detected","timestamp":"2025-01-02T10:30:00Z","severity":"HIGH"}'
```

## Application Integration

### Python Example
```python
import boto3
import json
from datetime import datetime

class SESEmailService:
    def __init__(self, region='us-east-1'):
        self.ses_client = boto3.client('ses', region_name=region)
        self.source_email = 'cicloudforteaimlnotifications@unisys.com'
        self.configuration_set = 'sc-ses-emailservice-demo-config-set'
    
    def send_simple_email(self, to_email, subject, message):
        """Send a simple text email"""
        try:
            response = self.ses_client.send_email(
                Source=self.source_email,
                Destination={'ToAddresses': [to_email]},
                Message={
                    'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                    'Body': {'Text': {'Data': message, 'Charset': 'UTF-8'}}
                },
                ConfigurationSetName=self.configuration_set
            )
            return response['MessageId']
        except Exception as e:
            print(f"Error sending email: {str(e)}")
            return None
    
    def send_templated_email(self, to_email, template_name, template_data):
        """Send an email using a template"""
        try:
            response = self.ses_client.send_templated_email(
                Source=self.source_email,
                Destination={'ToAddresses': [to_email]},
                Template=template_name,
                TemplateData=json.dumps(template_data),
                ConfigurationSetName=self.configuration_set
            )
            return response['MessageId']
        except Exception as e:
            print(f"Error sending templated email: {str(e)}")
            return None
    
    def send_notification(self, to_email, notification_type, subject, message):
        """Send a notification email"""
        template_data = {
            'notification_type': notification_type,
            'subject': subject,
            'message': message
        }
        return self.send_templated_email(to_email, 'notification_email', template_data)
    
    def send_alert(self, to_email, alert_type, alert_message, severity='MEDIUM'):
        """Send an alert email"""
        template_data = {
            'alert_type': alert_type,
            'alert_message': alert_message,
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'severity': severity
        }
        return self.send_templated_email(to_email, 'alert_email', template_data)

# Usage example
email_service = SESEmailService()

# Send a simple notification
email_service.send_notification(
    'team@unisys.com',
    'Deployment',
    'Production Release v2.1.0',
    'The production deployment has completed successfully. All systems are operational.'
)

# Send an alert
email_service.send_alert(
    'oncall@unisys.com',
    'High CPU Usage',
    'CPU usage has exceeded 90% on production servers',
    'HIGH'
)
```

### Lambda Function Example
```python
import json
import boto3
import os

def lambda_handler(event, context):
    """Lambda function to send SES emails"""
    
    ses_client = boto3.client('ses')
    
    # Get configuration from environment variables
    source_email = os.environ['SES_FROM_EMAIL']
    configuration_set = os.environ['SES_CONFIGURATION_SET']
    
    try:
        # Extract email details from event
        to_email = event['to_email']
        subject = event['subject']
        message = event['message']
        template = event.get('template')
        template_data = event.get('template_data', {})
        
        if template:
            # Send templated email
            response = ses_client.send_templated_email(
                Source=source_email,
                Destination={'ToAddresses': [to_email]},
                Template=template,
                TemplateData=json.dumps(template_data),
                ConfigurationSetName=configuration_set
            )
        else:
            # Send simple email
            response = ses_client.send_email(
                Source=source_email,
                Destination={'ToAddresses': [to_email]},
                Message={
                    'Subject': {'Data': subject, 'Charset': 'UTF-8'},
                    'Body': {'Text': {'Data': message, 'Charset': 'UTF-8'}}
                },
                ConfigurationSetName=configuration_set
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Email sent successfully',
                'messageId': response['MessageId']
            })
        }
        
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to send email',
                'details': str(e)
            })
        }
```

## Monitoring and Alerting

### CloudWatch Metrics
- **Send**: Number of emails sent
- **Bounce**: Number of bounced emails
- **Complaint**: Number of complaint notifications
- **Delivery**: Number of successful deliveries
- **Open**: Number of emails opened (if tracking enabled)
- **Click**: Number of links clicked (if tracking enabled)

### Alarm Thresholds
- **Sending Quota**: 80% of daily limit
- **Bounce Rate**: 5% (AWS recommends <5%)
- **Complaint Rate**: 0.1% (AWS recommends <0.1%)

### Alarm Actions
All alarms send notifications to: `sc-ses-emailservice-demo-ses-alarms` SNS topic

## Security and Compliance

### Email Security
- **TLS Encryption**: Required for all email transmission
- **DKIM**: Not configured (domain-based, requires domain ownership)
- **SPF**: Not configured (domain-based, requires DNS access)

### Access Control
- **IAM Role**: Dedicated role for sending emails
- **Least Privilege**: Only necessary SES permissions granted
- **Identity Policies**: Control who can send from verified identities

### Compliance Features
- **Bounce Handling**: Automatic bounce notifications
- **Complaint Handling**: Automatic complaint notifications
- **Suppression List**: Account-level suppression for bounces and complaints
- **Audit Logging**: All email events logged to CloudWatch

## Best Practices

### Email Deliverability
1. **Monitor Bounce Rates**: Keep below 5%
2. **Monitor Complaint Rates**: Keep below 0.1%
3. **Use Double Opt-in**: For subscription-based emails
4. **Maintain Clean Lists**: Remove invalid addresses promptly
5. **Authenticate Emails**: Implement DKIM and SPF when possible

### Cost Optimization
1. **Use Templates**: Reduce API calls and ensure consistency
2. **Monitor Usage**: Track sending patterns and optimize
3. **Shared IPs**: Use shared IPs for lower volume sending
4. **Log Retention**: Adjust based on compliance requirements

### Operational Excellence
1. **Error Handling**: Implement retry logic for transient failures
2. **Rate Limiting**: Respect SES sending limits
3. **Testing**: Test email templates and delivery
4. **Monitoring**: Set up comprehensive monitoring and alerting

## Troubleshooting

### Common Issues

1. **Email not verified**:
   ```bash
   aws ses verify-email-identity --email-address cicloudforteaimlnotifications@unisys.com
   ```

2. **Sending quota exceeded**:
   ```bash
   aws ses get-send-quota
   ```

3. **High bounce rate**:
   - Check email addresses for validity
   - Review bounce notifications in SNS topic
   - Clean up mailing lists

4. **Emails in spam folder**:
   - Check complaint rate
   - Implement authentication (DKIM, SPF)
   - Review email content for spam triggers

### Debugging Commands

```bash
# Check identity verification status
aws ses get-identity-verification-attributes --identities cicloudforteaimlnotifications@unisys.com

# Get sending statistics
aws ses get-send-statistics

# Check sending quota
aws ses get-send-quota

# List configuration sets
aws ses list-configuration-sets

# Get reputation for identity
aws ses get-identity-reputation --identity cicloudforteaimlnotifications@unisys.com

# List suppressed destinations
aws sesv2 list-suppressed-destinations
```

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: Email Services Team
- `contactName`: Lisa Chen
- `costBucket`: development
- `dataOwner`: Communications Team
- `displayName`: SC SES Email Service Demo Development
- `environment`: dev
- `hasPublicIP`: false
- `hasUnisysNetworkConnection`: true
- `serviceLine`: Communication Services

## Production Considerations

### Before Moving to Production
1. **Request Production Access**: Move out of SES sandbox
2. **Implement Domain Authentication**: Set up DKIM and SPF records
3. **Configure Dedicated IPs**: For high-volume sending
4. **Set up Proper DNS**: For domain-based sending
5. **Implement Advanced Monitoring**: Custom metrics and dashboards
6. **Create Runbooks**: For incident response procedures

### Scaling Considerations
1. **Sending Limits**: Request limit increases as needed
2. **Dedicated IP Warmup**: Plan IP warming schedule
3. **Multiple Regions**: Consider multi-region deployment
4. **Load Balancing**: Distribute sending across multiple identities

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Ensure all email templates and important configurations are backed up before destroying the environment.
