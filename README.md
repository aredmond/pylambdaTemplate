# pylambdaTemplate
Python AWS Lambda function with bash automation scripts

### Getting Started

Bootstrap the stack
```
./bootstrap.sh create
```
Change some files and update the lambda
```
./bootstrap.sh update
```
Tear the stack down after deving
```
./bootstrap.sh delete
```

### Create the stack

Build the lambda function by packaging the python file and its dependencies in a zip file  
```
cd lambda
./build-lambda-zip.sh
```

Create the IAM Role for the lambda function. This creates an IAM role and two managed policies  
```
cd iam
./iam-role-bootstrap.sh create
```

Finally create the lambda function
```
cd lambda
./deploy-lambda.sh create
```

### Updating the stack

To update the lambda code rebuild the zip then deploy the zip
```
cd lambda
./build-lambda-zip.sh
./deploy-lambda.sh update
```

To update the IAM policies do the following  
```
cd iam
./iam-role-bootstrap.sh update
```

### Deleting the stack

Delete the lambda then the IAM role and policies
```
cd lambda
./deploy-lambda.sh delete
cd ../iam
./iam-role-bootstrap.sh delete
```
