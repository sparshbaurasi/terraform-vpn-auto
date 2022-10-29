resource "aws_ec2_client_vpn_endpoint" "client-vpn-ep" {
  description            = var.client_vpn_description
  server_certificate_arn = file(var.server_certificate_arn)
  client_cidr_block      = var.client_cidr_block
    provisioner "local-exec" {
    command = "aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${self.id} --output text > first_user.ovpn"
  }

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = file(var.root_certificate_chain_arn)
  }
  
  connection_log_options {
    enabled               = false
  }
  split_tunnel = true
  vpc_id = var.vpc_id
  
}

resource "aws_ec2_client_vpn_network_association" "example-na-1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
  subnet_id              = var.subnet_id
}

# resource "aws_ec2_client_vpn_network_association" "example-na-2" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
#   subnet_id              = var.assoc_subnet_id_2
# }


resource "aws_ec2_client_vpn_authorization_rule" "example-ingress" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
  target_network_cidr    = var.target_network_cidr
  authorize_all_groups   = true
}

# resource "aws_ec2_client_vpn_route" "example-rtb-1" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
#   destination_cidr_block = var.destination_cidr_block
#   target_vpc_subnet_id   = var.target_vpc_subnet_id
# }