resource "aws_ec2_client_vpn_endpoint" "client-vpn-ep" {
  description            = var.client_vpn_description
  server_certificate_arn = file(var.server_certificate_arn)
  client_cidr_block      = var.client_cidr_block
    provisioner "local-exec" {
    command = <<-EOT
    aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${self.id} --output text > first_user.ovpn
    printf "\n<cert>" >> first_user.ovpn
    printf "\n`cat vpn-bash/acm/`cat client_arn`.crt`" >> first_user.ovpn
    printf "\n</cert>" >> first_user.ovpn
    printf "\n<key>" >> first_user.ovpn
    printf "\n`cat vpn-bash/acm/`cat client_arn`.key`" >> first_user.ovpn
    printf "\n</key>" >> first_user.ovpn
    EOT
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

resource "aws_ec2_client_vpn_network_association" "network_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
  subnet_id              = var.subnet_id
}


resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn-ep.id
  target_network_cidr    = var.target_network_cidr
  authorize_all_groups   = true
}
