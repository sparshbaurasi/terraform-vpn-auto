DIR="$( cd "$( dirname "$0" )" && pwd )"
echo $DIR
#ServerFile Creation
if aws acm list-certificates --query CertificateSummaryList[].[CertificateArn,DomainName]   --output text | grep server;
then 
echo "Server File Exist"
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

# terraform init
# terraform plan
# terraform apply