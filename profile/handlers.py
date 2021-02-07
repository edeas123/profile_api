import json
from visitor import record_visit

ALLOWED_ORIGINS = ["https://www.iamobaro.com", "https://iamobaro.com"]


# lambda logic only
def create(event, context):

    # get data from event object
    request_headers = event.get("headers", None)

    if request_headers:
        ip_address = request_headers.get("X-Forwarded-For", "localhost")
        table_name = "ProfileVisitor"
        status_code, body = record_visit(ip_address=ip_address, table_name=table_name)

        origin = request_headers.get("origin", None)
        headers = {}
        if origin in ALLOWED_ORIGINS:
            headers["Access-Control-Allow-Origin"] = origin

        return {
            'statusCode': status_code,
            'headers': headers,
            'body': json.dumps(body)
        }

    return {
        'statusCode': 400,
        'body': json.dumps({})
    }
