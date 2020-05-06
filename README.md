# aws-fargate-ecr-test
Testing connectivity between Fargate &amp; ECR (VPCLink/NAT/IG and Public/Private Subnets)


### public-subnet-ig
* public subnet (has route table pointing to Internet Gateway)
* ECS task has a public IP
* This works - connects to ECR

### private-subnet-ig
* private subnet (has route table pointing to NAT Gateway)
* ECS task has a public IP
* This does not work - Cannot connect to ECR error

* variants
 * assign_public_ip = false/true - no difference