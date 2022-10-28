resource "aws_ec2_client_vpn_endpoint" "client-vpn-ep" {
  description            = "terraform-clientvpn-endpoint"
  server_certificate_arn = "arn:aws:acm:ap-south-1:612490972332:certificate/06f09a0a-6a9b-4fc4-8f46-9113d729444f"
  client_cidr_block      = "10.0.0.0/22"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:ap-south-1:612490972332:certificate/37b1cb01-6ba9-4826-8328-28deb2f7f76a"
  }
  
  connection_log_options {
    enabled               = false
  }
  split_tunnel = true
  vpc_id = "vpc-076eb55458a972272"
  
}

resource "aws_ec2_client_vpn_network_association" "example-na-1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
  subnet_id              = "subnet-0a007b904b5e35448"
}

# resource "aws_ec2_client_vpn_network_association" "example-na-2" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
#   subnet_id              = var.assoc_subnet_id_2
# }


resource "aws_ec2_client_vpn_authorization_rule" "example-ingress" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
  target_network_cidr    = "10.0.0.0/16"
  authorize_all_groups   = true
}

# resource "aws_ec2_client_vpn_route" "example-rtb-1" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
#   destination_cidr_block = var.destination_cidr_block
#   target_vpc_subnet_id   = var.target_vpc_subnet_id
# }


