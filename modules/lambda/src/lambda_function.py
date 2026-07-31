import json
import os
import boto3
from datetime import datetime

ec2 = boto3.client("ec2")

def lambda_handler(event, context):

    response = ec2.describe_instances(
        Filters=[
            {
                "Name": "tag:Project",
                "Values": [os.environ["PROJECT_NAME"]]
            },
            {
                "Name": "tag:Environment",
                "Values": [os.environ["ENVIRONMENT"]]
            }
        ]
    )

    running = 0
    stopped = 0

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            state = instance["State"]["Name"]

            if state == "running":
                running += 1
            else:
                stopped += 1

    report = {
        "project": os.environ["PROJECT_NAME"],
        "environment": os.environ["ENVIRONMENT"],
        "region": os.environ["AWS_REGION"],
        "time": datetime.utcnow().isoformat(),
        "running_instances": running,
        "stopped_instances": stopped,
        "status": "Healthy"
    }

    print(json.dumps(report, indent=2))

    return report