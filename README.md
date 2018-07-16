# re-observe-pagerduty

Terraform configuration to manage the RE Observe team Pagerduty set up.

## Setup ##

### Install Terraform

```shell
brew install tfenv
tfenv install # this will pick up the version from .terraform-version
```

### Set up AWS Vault so you can assume AWS roles

To assume the needed role in AWS to run Terraform we are using the [AWS Vault](https://github.com/99designs/aws-vault) tool.

First, follow the instructions in the AWS Vault project to configure your environment.

We store the Terraform state in an S3 bucket in our Prometheus production AWS account so you should use the corresponding AWS vault profile for that account. You should be able to find the required variables to configure your profile using the AWS web console.

You should end up with something similar to this in your `.aws/config` file:

```
[profile <profile-name>]
role_arn=arn:aws:iam::<account-number>:role/<iam-role-name>
mfa_serial=arn:aws:iam::<iam-user-id>:mfa/<iam-user-name>
```

### Running Terraform

Before running Terraform you will need to make a copy of the `environment_sample.sh` to `environment.sh`. You will need to fill in the blank variables and source the file:

```shell
source environment.sh
```

You can now run Terraform using the provided Makefile:

```shell
make init           # Initialise terraform
make plan           # Plan terraform
make apply          # Apply terraform, auto approves
```

Execute `make` to give you a list of other possible commands to run.


## License
[MIT License](LICENCE)
