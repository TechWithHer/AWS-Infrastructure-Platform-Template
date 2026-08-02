import boto3


def get_cost():

    ec2 = boto3.client("ec2")

    volumes = ec2.describe_volumes(
        Filters=[
            {
                "Name": "status",
                "Values": ["available"]
            }
        ]
    )

    eips = ec2.describe_addresses()

    idle_addresses = []

    for ip in eips["Addresses"]:

        if "InstanceId" not in ip:

            idle_addresses.append(ip["PublicIp"])

    stopped = ec2.describe_instances(
        Filters=[
            {
                "Name": "instance-state-name",
                "Values": ["stopped"]
            }
        ]
    )

    stopped_instances = sum(
        len(r["Instances"])
        for r in stopped["Reservations"]
    )

    return {

        "unused_volumes": len(volumes["Volumes"]),

        "idle_eips": len(idle_addresses),

        "stopped_instances": stopped_instances

    }