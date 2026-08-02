import boto3

REQUIRED_TAGS = [
    "Project",
    "Environment",
    "ManagedBy",
    "Owner"
]


def get_governance():

    ec2 = boto3.client("ec2")

    reservations = ec2.describe_instances()["Reservations"]

    violations = []

    for reservation in reservations:

        for instance in reservation["Instances"]:

            tags = {
                tag["Key"]: tag["Value"]
                for tag in instance.get("Tags", [])
            }

            missing = []

            for required in REQUIRED_TAGS:

                if required not in tags:
                    missing.append(required)

            if missing:

                violations.append({

                    "instance_id": instance["InstanceId"],

                    "missing_tags": missing

                })

    return {

        "resources_with_missing_tags": len(violations),

        "violations": violations

    }