import json
import boto3 

dynamodb = boto3.resource('dynamodb') 
table = dynamodb.Table('visitor-count') # type: ignore

def lambda_handler(event, context):
    response = table.update_item(
        Key={
            'id': 'resume'
        },
        UpdateExpression='SET #c = if_not_exists(#c, :start) + :inc',
        ExpressionAttributeNames={
            '#c': 'count'
        },
        ExpressionAttributeValues={
            ':inc': 1,
            ':start': 0
        },
        ReturnValues='UPDATED_NEW'
    )

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'count': int(response['Attributes']['count'])
        })
    }