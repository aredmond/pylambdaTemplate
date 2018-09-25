# pylambdaTemplate
Python AWS Lambda function with bash automation scripts

### Getting Started

Build the lambda function by packaging the python file and its dependencies in a zip file  
```
./build-lambda-zip.sh
```

Create the IAM Role for the lambda function. This creates an IAM role and two managed policies  
```
./iam-role-bootstrap.sh create
```

Finally create the lambda function
```
./deploy-lambda.sh create
```

### Updating the stack

To update the lambda code rebuild the zip then deploy the zip
```
./build-lambda-zip.sh
./deploy-lambda.sh update
```

To update the IAM policies do the following  
```
./iam-role-bootstrap.sh update
```

### Deleting the stack

Delete the lambda then the IAM role and policies
```
./deploy-lambda.sh delete
./iam-role-bootstrap.sh delete
```
