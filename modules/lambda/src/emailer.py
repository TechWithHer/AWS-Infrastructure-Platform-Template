import json


def send_report(report):

    print(json.dumps(report, indent=4))