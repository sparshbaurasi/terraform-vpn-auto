resource "aws_ec2_client_vpn_endpoint" "client-vpn-ep" {
  description            = var.client_vpn_description
  server_certificate_arn = file(var.server_certificate_arn)
  client_cidr_block      = var.client_cidr_block

  tags = {
      Name        = var.vpn_name
    }
    provisioner "local-exec" {
    command = <<-EOT
    client_name=`cat client_name`
    aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${self.id} --output text > $client_name.ovpn
    printf "\n<cert>\n" >> $client_name.ovpn
    cat vpn-bash/acm/$client_name.crt >> $client_name.ovpn
    printf "</cert>\n" >> $client_name.ovpn
    printf "\n<key>\n" >> $client_name.ovpn
    cat vpn-bash/acm/$client_name.key >> $client_name.ovpn
    printf "</key>" >> $client_name.ovpn
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
