from __future__ import print_function

import time
import os
import boto3
import botocore
import requests
from botocore.client import Config
import json

def s3_to_json(bucket,key):
    s3 = boto3.client('s3', config=Config(signature_version='s3v4'))
    s3.download_file(bucket, key, '/tmp/input.json')

    with open('/tmp/input.json') as data_file:
        input_data = json.load(data_file)
    return input_data

def get_ipinfo():
    r = requests.get('https://ipinfo.io')
    return r.content

def publish_stackmap_to_s3(stackmapdict, coast):
    s3 = boto3.resource('s3')

    if coast == 'east':
        mapFileName = 'prodEastMap.json'
    else:
        mapFileName = 'prodWestMap.json'

    with open('/tmp/stackmap.json', 'w') as stackmap_file:
        json.dump(stackmapdict, stackmap_file, indent=4)

    s3.meta.client.upload_file('/tmp/stackmap.json', 'stackmap', mapFileName, ExtraArgs={'ContentType': 'application/json'})

def pylambda_handler(event, context):
    current_region = os.environ['AWS_DEFAULT_REGION']

    # if 'east' in current_region:
    #     prod_coast='east'
    # else:
    #     prod_coast='west'

    print(get_ipinfo())
    print("ChangeCodeTest")

    return True
