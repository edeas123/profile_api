from profile.visitor import record_visit
from moto import mock_dynamodb2
import boto3, os, pytest

IPADDRESS_1 = "70.215.174.90"
IPADDRESS_2 = "115.31.31.206"


@pytest.fixture(scope="function")
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"


def create_table(table_name):
    client = boto3.client("dynamodb")
    _ = client.create_table(
        TableName=table_name,
        AttributeDefinitions=[
            {
                "AttributeName": "IPAddress",
                "AttributeType": "S"
            }
        ],
        KeySchema=[
            {
                'AttributeName': 'IPAddress',
                'KeyType': 'HASH'
            }
        ]
    )


@mock_dynamodb2
@pytest.mark.usefixtures("aws_credentials")
def test_record_two_visitors():
    # test that two different visitors will count as 2 unique visitor with single visits
    table_name = "TestProfileVisitor"
    create_table(table_name)

    code_1, response_1 = record_visit(ip_address=IPADDRESS_1, table_name=table_name)

    assert code_1 == 200
    assert response_1['unique_visits'] == 1
    assert response_1['visits'] == 1

    code_2, response_2 = record_visit(ip_address=IPADDRESS_2, table_name=table_name)

    assert code_2 == 200
    assert response_2['unique_visits'] == 2
    assert response_2['visits'] == 1


@mock_dynamodb2
@pytest.mark.usefixtures("aws_credentials")
def test_record_same_visitor_second_visit():
    # test that the same visitor will count as 1 unique visits with multiple visits
    table_name = "TestProfileVisitor"
    create_table(table_name)

    code_1, response_1 = record_visit(ip_address=IPADDRESS_1, table_name=table_name)
    assert code_1 == 200
    assert response_1['unique_visits'] == 1
    assert response_1['visits'] == 1

    code_2, response_2 = record_visit(ip_address=IPADDRESS_1, table_name=table_name)

    assert code_2 == 200
    assert response_2['unique_visits'] == 1
    assert response_2['visits'] == 2


# NOTE: There seem to be a difference in behavior between ReturnValues="UPDATED_NEW" in boto3 and in moto.
# In boto3, everything is still returned, in moto only the updated fields are returned.
