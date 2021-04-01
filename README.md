# terraform-aws-infrastructure

This repo shows how you can organize terraform code
for your infrastructure repo.


Terraform state is saved in S3 `your-prefix-tfstate` bucket, in multiple files,
at the path like `eu-west-1/ec2/dev/terraform.tfstate`
or `us-east-1/s3/terraform.tfstate` file per
directory.

The idea is to have state splitted per region/service, allowing
faster execution and collaboration.

Locks are placed in DynamoDB, taken before `plan` / `apply`.


## Step-by-step

### prepare an AWS account

Register new AWS account, login to AWS console,
create new user in IAM, assign `AdministratorAccess` policy to this user
(can be done by adding policy directly or to `admins` IAM group)

Logout as root user, login as newly created admin-user, enable MFA,
generate access/secret keys, put them in `aws configure --profile yourusername`

Check access by running `AWS_PROFILE=yourusername aws s3 ls`
you should see no errors (and no buckets on an empty AWS account).

### S3 state bucket

Go to AWS web console, create private S3 bucket `yourname-tfstate` for terraform state with `Bucket Versioning` enabled
