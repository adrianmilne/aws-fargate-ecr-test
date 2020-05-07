# aws-fargate-ecr-test
This project contains a number of discrete Terraform scripts to test different configurations of VPC/Subnet/Gateways/VPC Interfaces to understand better what the options are and which work/don't work when connecting to ECR in a different account from pubic/private subnets in another account.

### The Problem
We have 2 accounts - one hosts the ECR repo, and the other hosts the Fargate Task that pulls the image from that repo. Suitable trust has been set up between accounts.

Current connection is via VPC Endpoints (AWS PrivateLink) set up on a private subnet in the calling account. When a Fargate task runs in this subnet - it can pull the image fine. However, if a task tries to run in a different subnet - it fails with the error:

```Status reason	CannotPullContainerError: Error response from daemon: Get https://XXX.dkr.ecr.eu-west-2.amazonaws.com/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)```

### Solutions?
I think the second subnet should be able to make use of the VPC endpoint in the first subnet - but can't get that to work.

You can make the second subnet public by adding an Internet Gateway/Route Table - that works. 

In theory you should also be able to do this by keeping the second subnet private and using a NAT Gateway to connect - but can't get this to work.


### Running the examples
CD to the relevant example folder

```terraform apply -var="role_arn=arn:aws:iam::{ECR_Account_Number}:role/{Role}"```


### Useful Links

* https://github.com/aws/amazon-ecs-agent/issues/1266
* https://github.com/aws/amazon-ecs-agent/issues/1128
* https://dev.to/danquack/private-fargate-deployment-with-vpc-endpoints-1h0p