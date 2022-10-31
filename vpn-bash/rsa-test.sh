if (($# >= 3)); 
then    
    DIR="$( cd "$( dirname "$0" )" && pwd )"
    echo $DIR
    #ServerFile Creation
    cd $DIR
    if aws acm list-certificates --query CertificateSummaryList[].[CertificateArn,DomainName]   --output text | grep server;
    then 
        echo "Server Certificate Already Uploaded to ACM"
    else
        cd $DIR
        git clone https://github.com/OpenVPN/easy-rsa.git 

        ./easy-rsa/easyrsa3/easyrsa init-pki
        cp -R $DIR/template/. pki/
        cp $DIR/template/easyrsa ./easy-rsa/easyrsa3/easyrsa
        ./easy-rsa/easyrsa3/easyrsa build-ca nopass
        ./easy-rsa/easyrsa3/easyrsa build-server-full server nopass
        mkdir acm
        cp pki/ca.crt acm
        cp pki/issued/server.crt acm
        cp pki/private/server.key acm
        aws acm import-certificate --certificate fileb://acm/server.crt --private-key fileb://acm/server.key --certificate-chain fileb://acm/ca.crt
    fi

    #Client ADD or DELETE

    if [ $2 = "ADD" ]; then
        ./easy-rsa/easyrsa3/easyrsa build-client-full $1 nopass
        cp pki/issued/$1.crt acm
        cp pki/private/$1.key acm
        aws acm import-certificate --certificate fileb://acm/$1.crt --private-key fileb://acm/$1.key --certificate-chain fileb://acm/ca.crt
        echo 'User added'
    elif [ $2 = "DELETE" ]; then
        ./easy-rsa/easyrsa3/easyrsa revoke $1
        aws acm list-certificates --query CertificateSummaryList[].[CertificateArn,DomainName]   --output text | grep $1 | cut -f1 > arn_to_delete
        aws acm delete-certificate --certificate-arn `cat arn`
        echo 'User deleted'
    else
        echo 'Enter a valid operation'
    fi

    cd ..

    aws acm list-certificates --query CertificateSummaryList[].[CertificateArn,DomainName]   --output text | grep server | cut -f1 > server_arn
    truncate -s-1 server_arn
    aws acm list-certificates --query CertificateSummaryList[].[CertificateArn,DomainName]   --output text | grep $1 | cut -f1 > client_arn
    truncate -s-1 client_arn

    endpoint=$(aws ec2 describe-client-vpn-endpoints --query 'ClientVpnEndpoints[?not_null(Tags[?Value == `'$3'`].Value)].ClientVpnEndpointId' --output text)
    if [ $3 = "terraform" ]; then
        aws acm list-certificates --query CertificateSummaryList[].[CertificateArn,DomainName]   --output text | grep $1 | cut -f2 > client_name
        truncate -s-1 client_name
        terraform init
        terraform plan
        terraform apply -auto-approve
    elif [ $2 = "ADD" && ! -z $endpoint  && ! -z $3 ]; then
        aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${endpoint} --output text > client_$1.ovpn
        printf "\n<cert>" >> client_$1.ovpn
        printf "\n`cat vpn-bash/acm/$1.crt`" >> client_$1.ovpn
        printf "\n</cert>" >> client_$1.ovpn
        printf "\n<key>" >> client_$1.ovpn
        printf "\n`cat vpn-bash/acm/$1.key`" >> client_$1.ovpn
        printf "\n</key>" >> client_$1.ovpn
    else
        echo 'Enter a valid operation'
    fi
else
    echo 'Error: Got '$#' Minimum 3 Arguments are Required' >&2
    exit 5
fi