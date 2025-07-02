
# CloudWatch Development Environment

This environment deploys the sc-cw-monitoring-demo CloudWatch infrastructure for comprehensive monitoring and logging.

## Prerequisites

Before deploying this environment, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **CloudWatch permissions** for creating and managing monitoring resources

## CloudWatch Configuration

### Log Groups
- **Application Logs**: `/aws/application/sc-cw-monitoring-demo` (30-day retention)
- **System Logs**: `/aws/system/sc-cw-monitoring-demo` (14-day retention)
- **Security Logs**: `/aws/security/sc-cw-monitoring-demo` (90-day retention)
- **Lambda Logs**: `/aws/lambda/sc-cw-monitoring-demo` (30-day retention)
- **API Gateway Logs**: `/aws/apigateway/sc-cw-monitoring-demo` (30-day retention)

### Metric Filters
- **Error Count**: Tracks ERROR messages in application logs
- **Warning Count**: Tracks WARN messages in application logs
- **Security Events**: Monitors security-related events
- **Lambda Errors**: Tracks Lambda function errors

### Dashboards
- **Infrastructure Dashboard**: EC2, RDS, Lambda, and EKS metrics
- **Application Dashboard**: Custom application metrics and recent errors

## Monitoring Components

### SNS Alerts
- **Topic**: CloudWatch alerts for notifications
- **Email Subscriptions**: admin@example.com, devops@example.com
- **SMS Subscriptions**: +1234567890

### Alarms
- **CPU Utilization**: Threshold 80%
- **Memory Utilization**: Threshold 85%
- **Disk Space**: Threshold 10GB free
- **RDS CPU**: Threshold 75%
- **RDS Connections**: Threshold 80
- **Lambda Errors**: Threshold 5 errors
- **Lambda Duration**: Threshold 30 seconds

### Custom Alarms
- **High Error Rate**: Application error threshold
- **Security Events**: Security incident detection

### Composite Alarm
- **Application Health**: Combines multiple alarms for overall health status

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

1. **View dashboards**:
   - Infrastructure: Use the infrastructure_dashboard_url output
   - Application: Use the application_dashboard_url output

2. **Test log ingestion**:
   ```bash
   aws logs put-log-events \
     --log-group-name "/aws/application/sc-cw-monitoring-demo" \
     --log-stream-name "test-stream" \
     --log-events timestamp=$(date +%s000),message="Test ERROR message"
   ```

3. **Run CloudWatch Insights queries**:
   ```bash
   aws logs start-query \
     --log-group-name "/aws/application/sc-cw-monitoring-demo" \
     --start-time $(date -d '1 hour ago' +%s) \
     --end-time $(date +%s) \
     --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20'
   ```

## CloudWatch Insights Queries

### Error Analysis
```
fields @timestamp, @message, @requestId
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
```

### Performance Analysis
```
fields @timestamp, @duration, @billedDuration, @memorySize, @maxMemoryUsed
| filter @type = "REPORT"
| stats avg(@duration), max(@duration), min(@duration) by bin(5m)
| sort @timestamp desc
```

### Security Analysis
```
fields @timestamp, @message
| filter @message like /SECURITY/
| sort @timestamp desc
| limit 50
```

### Lambda Cold Starts
```
fields @timestamp, @type, @requestId, @duration
| filter @message like /INIT_START/
| stats count() by bin(1h)
| sort @timestamp desc
```

### Request Analysis
```
fields @timestamp, @requestId, @message
| filter @message like /START RequestId/
| stats count() by bin(5m)
| sort @timestamp desc
```

## Monitoring Best Practices

### Log Management
- **Structured Logging**: Use JSON format for better parsing
- **Log Levels**: Implement proper log levels (ERROR, WARN, INFO, DEBUG)
- **Correlation IDs**: Include request IDs for tracing
- **Retention Policies**: Set appropriate retention based on compliance needs

### Alerting Strategy
- **Tiered Alerts**: Different thresholds for different severity levels
- **Alert Fatigue**: Avoid too many false positives
- **Escalation**: Define escalation paths for critical alerts
- **Documentation**: Include runbooks for alert responses

### Dashboard Design
- **Key Metrics**: Focus on business-critical metrics
- **Time Ranges**: Use appropriate time ranges for different views
- **Drill-down**: Enable easy navigation from high-level to detailed views
- **Real-time**: Balance real-time updates with performance

## Integration Examples

### Application Logging
```python
import json
import logging
import uuid

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

def lambda_handler(event, context):
    request_id = str(uuid.uuid4())
    
    try:
        # Your application logic
        result = process_request(event)
        
        logging.info(json.dumps({
            'request_id': request_id,
            'event': 'request_processed',
            'status': 'success'
        }))
        
        return result
        
    except Exception as e:
        logging.error(json.dumps({
            'request_id': request_id,
            'event': 'request_failed',
            'error': str(e),
            'status': 'error'
        }))
        raise
```

### Custom Metrics
```python
import boto3

cloudwatch = boto3.client('cloudwatch')

def put_custom_metric(metric_name, value, unit='Count'):
    cloudwatch.put_metric_data(
        Namespace='Application/Custom',
        MetricData=[
            {
                'MetricName': metric_name,
                'Value': value,
                'Unit': unit,
                'Dimensions': [
                    {
                        'Name': 'Environment',
                        'Value': 'dev'
                    }
                ]
            }
        ]
    )
```

### Error Tracking
```python
import boto3
import json
from datetime import datetime

def track_error(error_type, error_message, context=None):
    """Track application errors for monitoring"""
    
    error_data = {
        'timestamp': datetime.utcnow().isoformat(),
        'error_type': error_type,
        'error_message': error_message,
        'context': context or {}
    }
    
    # Log to CloudWatch
    print(f"ERROR {json.dumps(error_data)}")
    
    # Send custom metric
    cloudwatch = boto3.client('cloudwatch')
    cloudwatch.put_metric_data(
        Namespace='Application/Errors',
        MetricData=[
            {
                'MetricName': 'ErrorCount',
                'Value': 1,
                'Unit': 'Count',
                'Dimensions': [
                    {
                        'Name': 'ErrorType',
                        'Value': error_type
                    },
                    {
                        'Name': 'Environment',
                        'Value': 'dev'
                    }
                ]
            }
        ]
    )
```

## Alarm Response Procedures

### High CPU Utilization
1. **Check dashboard** for current CPU usage trends
2. **Investigate processes** consuming high CPU
3. **Scale resources** if needed
4. **Review application performance** for optimization opportunities

### High Error Rate
1. **Check application logs** for error details
2. **Identify error patterns** and root causes
3. **Deploy fixes** if application issues found
4. **Monitor recovery** after fixes applied

### Security Events
1. **Immediate investigation** of security alerts
2. **Check access logs** for suspicious activity
3. **Isolate affected resources** if necessary
4. **Document incident** and response actions

### Lambda Performance Issues
1. **Review function logs** for errors and timeouts
2. **Check memory usage** and duration metrics
3. **Optimize function code** if performance issues found
4. **Adjust memory allocation** if needed

## Cost Optimization

### Log Retention
- **Application logs**: 30 days (adjust based on compliance needs)
- **System logs**: 14 days (sufficient for troubleshooting)
- **Security logs**: 90 days (compliance requirement)

### Dashboard Optimization
- **Limit widgets**: Keep dashboards focused and performant
- **Use appropriate time ranges**: Avoid unnecessarily long time periods
- **Optimize queries**: Use efficient CloudWatch Insights queries

### Alarm Management
- **Review alarm effectiveness**: Remove unused or ineffective alarms
- **Optimize thresholds**: Adjust to reduce false positives
- **Use composite alarms**: Reduce alarm noise with logical combinations

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: Monitoring Team
- `contactName`: Robert Kim
- `costBucket`: development
- `dataOwner`: Operations Team
- `displayName`: SC CloudWatch Monitoring Demo Development
- `environment`: dev
- `hasPublicIP`: false
- `hasUnisysNetworkConnection`: false
- `serviceLine`: Monitoring Services

## Troubleshooting

### Common Issues

1. **Log ingestion delays**:
   - Check CloudWatch agent configuration
   - Verify IAM permissions for log publishing
   - Monitor CloudWatch service health

2. **Missing metrics**:
   - Verify metric filters are correctly configured
   - Check log group names and patterns
   - Ensure applications are logging in expected format

3. **Alarm not triggering**:
   - Verify alarm configuration and thresholds
   - Check metric data availability
   - Review alarm history for state changes

4. **Dashboard not loading**:
   - Check widget configurations
   - Verify metric names and namespaces
   - Review CloudWatch service limits

### Debugging Commands

```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/"

# Get metric statistics
aws cloudwatch get-metric-statistics \
  --namespace "Application/Errors" \
  --metric-name "ErrorCount" \
  --start-time "2025-01-02T00:00:00Z" \
  --end-time "2025-01-02T23:59:59Z" \
  --period 3600 \
  --statistics Sum

# List alarms
aws cloudwatch describe-alarms --alarm-names "sc-cw-monitoring-demo-high-error-rate"

# Test SNS topic
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-1:123456789012:sc-cw-monitoring-demo-cloudwatch-alerts" \
  --message "Test notification"
```

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Ensure all log data is backed up if needed before destroying log groups.
