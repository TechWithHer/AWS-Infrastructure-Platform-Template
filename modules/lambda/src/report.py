from datetime import datetime


def build_report(
        project,
        environment,
        inventory,
        monitoring,
        governance,
        cost):

    return {

        "generated_at": datetime.utcnow().isoformat(),

        "project": project,

        "environment": environment,

        "inventory": inventory,

        "monitoring": monitoring,

        "governance": governance,

        "cost": cost,

        "status": "Healthy"

    }