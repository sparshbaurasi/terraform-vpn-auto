# Clone the Repo in your local machine to get started
Note : Make sure you are inside repo folder created on local machine

## If you want to create server and client file with terraform use the below command
Server Name is set to "server" by Default. If you want to change serve name it can be changed by changing variable value in PATH: vpn-bash/vpn-rsa.sh
```
./vpn-bash/vpn-rsa.sh example-clientname.com ADD terraform
```
Note : The above command is specifically for users who want to create clientvpn endpoint also. All Other Command which will help to ADD or DELETE VPN User to or from Exsisting ClientVPN Endpoint are mentioned at last of this file
- Explaination : 
 - At Index 0 - We are trying to run bash script inside vpn_bash folder
 - At Index 1 - We are giving clientname which user has to input for ADD/DELTE Option
 - At Index 2 - We are giving ADD or DELETE Argument which will help to add or delete the client from vpn endpoint
 - At Index 3 - We need to specify "terraform" if you dont have any server already on AWS Running and If already have ClientVPN running on AWS                             please provide name of the ClientVPN Server that will help to Download ClientConfig file on local machine
## Some Example Commands
```
./vpn-bash/vpn-rsa.sh example-clientname.com DELETE prodvpn-ep
./vpn-bash/vpn-rsa.sh example-clientname1.com ADD example-vpn-ep
./vpn-bash/vpn-rsa.sh example-clientname2.com ADD prodvpn-ep
```
