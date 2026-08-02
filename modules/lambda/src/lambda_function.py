import json
import os

from inventory import get_inventory
from monitoring import get_monitoring
from governance import get_governance
from cost import get_cost
from report import build_report
from emailer import send_report


def lambda_handler(event, context):

    project = os.environ["PROJECT_NAME"]
    environment = os.environ["ENVIRONMENT"]

    inventory = get_inventory(project, environment)

    monitoring = get_monitoring()

    governance = get_governance()

    cost = get_cost()

    report = build_report(
        project,
        environment,
        inventory,
        monitoring,
        governance,
        cost
    )

    send_report(report)

    return {
        "statusCode": 200,
        "body": json.dumps(report)
    }