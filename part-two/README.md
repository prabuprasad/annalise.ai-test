# How would you provide shell access into the application stack for operations staff who may want to log into an instance.

I will create a separate user and provide access only to the specific directory using "chown" command. Then I will generate username/password or pub/ppt key for the user to login.

# Make access and error logs available in a monitoring service such as AWS CloudWatch or Azure Monitor

Open the IAM console

In the navigation pane, choose Policies.

Choose Create policy.

On the Visual editor tab, choose Choose a service, and then choose CloudWatch Logs.

For Actions, choose Expand all (on the right), and then choose the Amazon CloudWatch Logs permissions needed for the IAM policy.

Ensure that the following permissions are selected:

    CreateLogGroup

    CreateLogStream

    DescribeLogStreams

    GetLogEvents

    PutLogEvents

    PutRetentionPolicy

Choose Resources and choose Add ARN for log-group.

In the Add ARN(s) dialog box, enter the following values:

    Region – An AWS Region or *

    Account – An account number or *

    Log Group Name – /aws/rds/*

In the Add ARN(s) dialog box, choose Add.

Choose Add ARN for log-stream.

In the Add ARN(s) dialog box, enter the following values:

    Region – An AWS Region or *

    Account – An account number or *

    Log Group Name – /aws/rds/*

    Log Stream Name – *

In the Add ARN(s) dialog box, choose Add.

Choose Review policy.

Set Name to a name for your IAM policy.

Choose Create policy.
