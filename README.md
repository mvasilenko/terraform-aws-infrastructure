# terraform-aws-infrastructure

This repo shows how you can organize terraform code
for your infrastructure repo.

Terraform state is saved in S3 `your-prefix-tfstate` bucket, in multiple files,
at the path like `eu-west-1/ec2/dev/terraform.tfstate`
or `us-east-1/s3/terraform.tfstate` file per
directory.

The idea is to have state splitted per region/service, allowing
faster `terraform plan/apply` execution and collaboration between team members.

Locks are placed in DynamoDB, taken before `plan` / `apply`.


## Step-by-step

### Install terraform

Download terraform, install it

Set TF_PLUGIN_CACHE_DIR env var to allow plugin caching

```shell script
export TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache
```

### prepare an AWS account

Register new AWS account, login to AWS console,
create new user in IAM, assign `AdministratorAccess` policy to this user
(can be done by adding policy directly or to `admins` IAM group)

Logout as root user, login as newly created admin-user, enable MFA,
generate access/secret keys, put them in `aws configure --profile yourusername`

Set active AWS CLI profile by exporting environment variable

```shell script
export AWS_PROFILE=yourusername
```

Check access by running `aws s3 ls`
you should see no errors (and no buckets on an empty AWS account).

### S3 state bucket

Go to AWS web console, create private S3 bucket `yourusername-tfstate` for terraform state with `Bucket Versioning` enabled

### DynamoDB locks

Create DynamoDB, needed for locks - allow only one change at a time.

Go to `terraform/eu-west-1/main` directory (`eu-west-1` is the same as S3 bucket region)

Review `.tf` files there

Run `terraform plan -lock=false`

Check changes, if they look good, apply it with `terraform apply -lock=false`

Check one more time with `terraform plan`, you should see

```shell script
No changes. Infrastructure is up-to-date.
```

### Network provisioning - VPC, public subnets

Go to `terraform/eu-west-1/network` directory

Review `.tf` files there, we are going to create VPC with 3 public subnets - one for each AZ

Run `terraform plan`

Check changes, if they look good, apply it with `terraform apply`

Check one more time with `terraform plan`, you should see
```shell script
No changes. Infrastructure is up-to-date.
```

During this step, security groups limiting access to AWS entities, like EC2/ECS/RDS/etc will be added:
* `local` - allow traffic inside VPC
* `ssh` - allow incoming ssh traffic
* `http_https` - allow incoming http/https traffic



