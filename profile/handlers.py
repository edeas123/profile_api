import json
from visitor import record_visit


# lambda logic only
def create(event, context):
    # get data from event object
    headers = event.get("headers", None)

    if headers:
        ip_address = headers.get("X-Forwarded-For", "localhost")
        status_code, body = record_visit(ip_address=ip_address)

        return {
            'statusCode': status_code,
            'headers': {
                'Access-Control-Allow-Origin': "*"
            },
            'body': json.dumps(body)
        }

    return {
        'statusCode': 400,
        'headers': {
           'Access-Control-Allow-Origin': "*"
        },
        'body': json.dumps({})
    }
