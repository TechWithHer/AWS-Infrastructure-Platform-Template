import boto3


def get_monitoring():

    cloudwatch = boto3.client("cloudwatch")
    sns = boto3.client("sns")

    alarms = cloudwatch.describe_alarms()

    topics = sns.list_topics()

    subscriptions = sns.list_subscriptions()

    return {

        "alarm_count": len(alarms["MetricAlarms"]),

        "alarms": [
            {
                "name": alarm["AlarmName"],
                "state": alarm["StateValue"],
                "metric": alarm["MetricName"]
            }
            for alarm in alarms["MetricAlarms"]
        ],

        "sns_topic_count": len(topics["Topics"]),

        "sns_subscription_count": len(subscriptions["Subscriptions"])

    }