
# Step Functions Development Environment

This environment deploys the sc-stepfn-demo Step Functions workflow with supporting Lambda functions and SNS notifications.

## Prerequisites

Before deploying this environment, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (version >= 1.0)
3. **Step Functions permissions** for creating and managing workflows

## Step Functions Configuration

- **State Machine Name**: sc-stepfn-demo
- **Type**: Standard workflow
- **Logging**: Enabled with ALL log level
- **Tracing**: X-Ray tracing enabled
- **Encryption**: Enabled with AWS managed keys
- **Execution Data**: Included in logs

## Workflow Components

### Lambda Functions
1. **hello-world**: Simple greeting function that returns success status
2. **process-data**: Data processing function with random success/failure simulation

### SNS Topic
- **notifications**: Receives workflow completion notifications (success/failure)

### Step Functions Workflow
The workflow follows this sequence:
1. **HelloWorld** - Invokes hello-world Lambda function
2. **ProcessData** - Invokes process-data Lambda function
3. **Choice** - Evaluates the processing result
4. **Success/Failure** - Publishes appropriate notification to SNS

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

1. **Start a workflow execution**:
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <state-machine-arn> \
     --name "test-execution-$(date +%s)" \
     --input '{"test": "data"}'
   ```

2. **List executions**:
   ```bash
   aws stepfunctions list-executions \
     --state-machine-arn <state-machine-arn>
   ```

3. **Get execution details**:
   ```bash
   aws stepfunctions describe-execution \
     --execution-arn <execution-arn>
   ```

4. **View execution history**:
   ```bash
   aws stepfunctions get-execution-history \
     --execution-arn <execution-arn>
   ```

## Monitoring and Logging

- **CloudWatch Logs**: `/aws/stepfunctions/sc-stepfn-demo`
- **Log Retention**: 14 days
- **X-Ray Tracing**: Enabled for performance monitoring
- **Execution Data**: Included in logs for debugging

## Workflow Definition

The Step Functions workflow uses Amazon States Language (ASL) and includes:

```json
{
  "Comment": "A simple Step Functions workflow for sc-stepfn-demo",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Next": "ProcessData"
    },
    "ProcessData": {
      "Type": "Task", 
      "Resource": "arn:aws:states:::lambda:invoke",
      "Next": "Choice"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.status",
          "StringEquals": "success",
          "Next": "Success"
        }
      ],
      "Default": "Failure"
    },
    "Success": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "End": true
    },
    "Failure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish", 
      "End": true
    }
  }
}
```

## Mandatory Tags

All resources are tagged with the following mandatory tags:
- `contactGroup`: Workflow Team
- `contactName`: Alex Thompson
- `costBucket`: development
- `dataOwner`: Process Automation Team
- `displayName`: SC Step Functions Demo Development
- `environment`: dev
- `hasPublicIP`: false
- `hasUnisysNetworkConnection`: false
- `serviceLine`: Workflow Services

## Testing the Workflow

1. **Test with success scenario**:
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <arn> \
     --name "success-test" \
     --input '{"message": "test success"}'
   ```

2. **Monitor execution in AWS Console**:
   - Go to Step Functions console
   - Select your state machine
   - View execution graph and logs

3. **Check SNS notifications**:
   ```bash
   aws sns list-subscriptions-by-topic \
     --topic-arn <sns-topic-arn>
   ```

## Error Handling

The workflow includes:
- **Retry logic**: Automatic retries for transient failures
- **Error notifications**: SNS alerts for failed executions
- **Detailed logging**: Full execution history in CloudWatch

## Cost Optimization

- **Standard workflow**: Cost-effective for long-running processes
- **Log retention**: 14 days to balance cost and debugging needs
- **Efficient Lambda**: Short timeout values to minimize costs

## Cleanup

To destroy the environment:
```bash
terraform destroy
```

**Note**: Ensure all executions are completed before destroying the state machine.
