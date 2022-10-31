# Clone the Repo in your local machine to get started
Note : Make sure you are inside repo folder created on local machine

## If you want to create server and client file with terraform use the below command
```
./vpn_bash/vpn_rsa.sh clientname.com ADD terraform
```
- Explaination : At Index 0 - We are trying to run bash script inside vpn_bash folder
               At Index 1 - We are giving clientname which user has to input for ADD/DELTE Option
               At Index 2 - We are giving ADD or DELETE Argument which will help to add or delete the client from vpn endpoint
               At Index 3 - We need to specify "terraform" if you dont have any server already on AWS Running and If already have ClientVPN running on AWS                             please provide name of the ClientVPN Server that will help to Download ClientConfig file on local machine
