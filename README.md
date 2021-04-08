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

Set active AWS CLI profile by exporting environment variable,
this is useful is you have multiple AWS accounts

```shell script
export AWS_PROFILE=yourusername
```

Check access by running `aws s3 ls`
you should see no errors (and no buckets on an empty AWS account).

### S3 state bucket

Go to AWS web console, create private S3 bucket `yourusername-tfstate` for terraform state with `Bucket Versioning` enabled

### DynamoDB locks

Create DynamoDB, needed for locks - allow only one change at a time.

Open `terraform/eu-west-1/main` directory (`eu-west-1` is the same as S3 bucket region)

Review `.tf` files there

Run `terraform plan -lock=false`

Check changes, if they look good, apply it with `terraform apply -lock=false`

Check one more time with `terraform plan`, you should see

```shell script
No changes. Infrastructure is up-to-date.
```

### Network provisioning - VPC, public subnets

Open `terraform/eu-west-1/network` directory

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

### IAM role provisioning

We need AWS to have IAM role for running container to be able to make requests to other AWS services,

Open `terraform/global/iam` directory

Review `.tf` files, in `flask_app.tf` there is an IAM policy with pull permissions to ECR repo access
with our app docker image

Run `terraform plan`

Check changes, if they look good, apply it with `terraform apply`

### ECS cluster

One of the ways of running dockerized apps in AWS is to use ECS cluster, it is managed container orchestrator.
Let's create ECS cluster named `app-dev`

Open `terraform/eu-west-1/ecs/app` directory

Review `.tf` files, in `cluster.tf` there is a definition of `app-dev` ECS cluster

Run `terraform plan`

Check changes, if they look good, apply it with `terraform apply`

### Create flask app, build and push app docker image

Sample app code is in `app/` directory, open it by `cd app`

Login to AWS ECR used by your AWS account id

```
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region=eu-west-1|docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com`
```

Build docker image and push it to ECR
If we will not specify the image tag, the default tag `:latest` will be used,
this is considered bad practice and should be avoided

```
export hash=$(git rev-parse --short HEAD)
docker build -t $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/flask-app:$hash app/
docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/flask-app:$hash
```

or just run `app/build.sh`

### Create Load balancer, listener

To receive traffic from internet, we need to create LoadBalancer,
listener (by protocol - HTTP/HTTPS)

open `terraform/eu-west-1/lb` directory,
review `.tf` files

Run `terraform plan`

Check changes, if they look good, apply it with `terraform apply`

### Create listener rule, target group

To run task in ECS we need to create task definition, service,
and attach service to load balancer via target group.

The idea below is to keep infrastructure code (target group, LB listener rules)
separated from the app code (task and service definitions),
the should be split to different repos.

Infrastructure code located in `terraform/eu-west-1/ecs/app`,
target group and load balancer listener rules defined there.

Open `terraform/eu-west-1/ecs/app` directory,
Review `.tf` files

Run `terraform plan`

Check changes, if they look good, apply it with `terraform apply`

### DNS (not covered)

For app to be available from the Internet, need to have desired hostname  resolved
to the LB by setting DNS record:

`flask.mvasilenko.me CNAME alb-12345678.eu-west-1.elb.amazonaws.com`

### Deploy application - first time

```shell script
cd app/deploy
terraform apply -var image_tag=$hash
```

### Deploy updates to the application

Make some changes in the app, like change "Hello world" to "Hello container" in `app.py`
Test and commit changes, so git commit hash will change

Rebuild app image by running `app/build.sh` or manually

```shell script
export hash=$(git rev-parse --short HEAD)
docker build --tag $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/flask-app:$hash app/
docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/flask-app:$hash
```

Deploy new version, updated image

```shell script
cd app/deploy
terraform apply -var image_tag=$hash
```

Go to ECS, select our `app-dev` cluster, `flask-app` service, check that tasks are running with new image

Open web page app
