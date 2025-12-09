import boto3
client = boto3.client('elbv2')
response = client.describe_trust_stores(Names=['your-trust-store-name'])
print(response)
