# Lambda CloudFormation Stack

## Tools needed to use these scripts

* awscli - for aws cli commands
* jq - for parsing json
* gettext - for envsubst command
```
brew install gettext
brew link --force gettext
```

## Creating the stack

The stack must be create before changesets with transforms can be create or applied

```
./create-stack.sh
```

The stackname is set in the script but can be changed by specifying the stack name with a -n

```
./create-stack.sh -n pylambda2
```

If you do change the name be sure include it in all script execution

## Create a Change Set

Change Sets will fail if no change is to be applied. This script will print the error and delete the change set if it does end up in a failed state.

```
./create-changeset.sh
```

## Execute change set

If the create change set script is successful the execution command will be printed for easy copy and paste execution. Otherwise here is the basic syntax.

```
./execute-changeset.sh pylambda-2018-09-24-21-18-04
```

## OverWriting stack parameters

The file `bootstrap_parameters.json` is pulled in and applied by all the above scripts. This file can be used to change the parameters in the template.
