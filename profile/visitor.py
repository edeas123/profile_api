import boto3
from datetime import datetime


def record_visit(ip_address, table_name):

    dynamodb = boto3.client('dynamodb')
    key = {
        "IPAddress": {
            "S": ip_address
        }
    }
    ts = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    response = dynamodb.update_item(
        TableName=table_name,
        Key=key,
        ReturnValues="ALL_NEW",
        ExpressionAttributeNames={
            '#NV': "NumberOfVisits",
            "#LV": "LastVisited",
            "#FV": "FirstVisited"
        },
        ExpressionAttributeValues={
            ":ts": {
                "S": ts
            },
            ":nv": {
                "N": "1"
            }
        },
        UpdateExpression="SET #LV = :ts, #FV = if_not_exists(#FV, :ts) ADD #NV :nv"
    )

    # use the 0.0.0.0 address to track the number of unique visits
    status_code = response["ResponseMetadata"]["HTTPStatusCode"]
    count = int(response["Attributes"]["NumberOfVisits"]["N"])
    first_visit = response["Attributes"]["FirstVisited"]["S"]

    uv = 0
    if count == 1:  # this was the first visit
        uv = 1

    local_key = {
        "IPAddress": {
            "S": "0.0.0.0"
        }
    }
    local_response = dynamodb.update_item(
        TableName=table_name,
        Key=local_key,
        ReturnValues="ALL_NEW",
        ExpressionAttributeValues={":uv": {"N": str(uv)}},
        UpdateExpression="ADD NumberOfUniqueVisits :uv"
    )
    unique_count = local_response["Attributes"]["NumberOfUniqueVisits"]["N"]

    return status_code, {
        "visits": count,
        "first_visit": first_visit,
        "unique_visits": int(unique_count)
    }
