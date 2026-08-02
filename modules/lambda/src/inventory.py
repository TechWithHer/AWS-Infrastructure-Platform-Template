import boto3


def get_inventory(project_name, environment):
    """
    Returns an inventory of EC2, VPCs and Subnets.
    """

    session = boto3.session.Session()
    ec2 = session.client("ec2")

    # -----------------------------
    # EC2 Instances
    # -----------------------------
    response = ec2.describe_instances(
        Filters=[
            {
                "Name": "tag:Project",
                "Values": [project_name]
            },
            {
                "Name": "tag:Environment",
                "Values": [environment]
            }
        ]
    )

    instances = []

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:

            name = ""

            for tag in instance.get("Tags", []):
                if tag["Key"] == "Name":
                    name = tag["Value"]

            instances.append({
                "instance_id": instance["InstanceId"],
                "name": name,
                "state": instance["State"]["Name"],
                "instance_type": instance["InstanceType"],
                "availability_zone": instance["Placement"]["AvailabilityZone"],
                "private_ip": instance.get("PrivateIpAddress"),
                "public_ip": instance.get("PublicIpAddress")
            })

    # -----------------------------
    # VPCs
    # -----------------------------
    vpcs = ec2.describe_vpcs()["Vpcs"]

    # -----------------------------
    # Subnets
    # -----------------------------
    subnets = ec2.describe_subnets()["Subnets"]

    return {
        "instance_count": len(instances),
        "instances": instances,
        "vpc_count": len(vpcs),
        "subnet_count": len(subnets)
    }