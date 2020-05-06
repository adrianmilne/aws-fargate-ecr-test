

resource "aws_vpc_endpoint" "vpc_endpoint_ecr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.allow_inbound_https.id
  ]

  subnet_ids          = [var.subnet_id]
  private_dns_enabled = var.private_dns_enabled
}

resource "aws_vpc_endpoint" "vpc_endpoint_cloudwatch" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.allow_inbound_https.id
  ]

  subnet_ids          = [var.subnet_id]
  private_dns_enabled = var.private_dns_enabled
}


resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids
}

resource "aws_security_group" "allow_inbound_https" {
  name        = "vpc_endpoint_ecr_allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "192.168.3.0/24"
    ]
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }
}
