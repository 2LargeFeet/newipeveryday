Are you a privacy concious individual? Do you not trust for profit VPN providers you heard about on YouTube? With New IP Everyday, you can easily create and connect to your own VPN server. Give yourself a new public IP address with `terraform destroy` and `terraform apply`.

For this project, you will need terraform and the openvpn client installed on your windows computer. You will also need the ssh client enabled in windows 10 to use the transfer local-exec terraform command at the end. Without the SSH client, it will fail and you'll need to use something like winscp to grab the client.ovpn file using scp or sftp. If you want to enable the SSH Client, here's a guide. https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse

Keep in mind, this tool will create a server in your AWS account restricted to your IP address. It's up to you to maintain it or destroy it if you don't want it anymore.

Instructions to setup NewIPEveryday:

1. Install Git on your computer. Clone this repo to your local computer.

2. Install OpenVPN for windows. https://openvpn.net/community-downloads/

3. Open the OpenVPN settings. Click on the `Advanced` tab. Enter the path to the cloned repo where it says 'Folder:'. Click OK.

4. In the AWS console, create a key pair to use. Save the .pem for your public key to the repo directory.

5. In the AWS console, create an IAM user with the ability to edit security groups, create instances, and destroy instances.

6. Create an Access Key for the IAM user you created. Make note of the access key ID and the access key secret in a secure way.

7. Create a file in the downloaded repo called 'secure.auto.tfvars'. It should contain the following.

        access_key         = Access key for IAM user you created  
        secret_key         = Secret key for IAM user you created  
        private_key        = NAME of the private key you created
        private_key_file   = The private key you created  you created
8. Install Terraform. https://www.terraform.io/downloads.html

9. Run the following commands from the cloned directory.

        terraform init #(Only need to run this the first time)
        terraform taint aws_instance.vpn  #(Don't worry if this errors on the first run)
        terraform plan
        terraform apply

10. Open OpenVPN. Right click the OpenVPN icon in your toolbar, and click `Connect`.

You should be connected to your own, secure VPN. Your IP address will be from somewhere in `us-east-1` by default. To get a new IP address simply run the above terraform commands again and connect with OpenVPN.

You can destory all of the infrastructure that terraform created by running `terraform destroy`.

Shoutouts to the great people at Hashicorp, Ansible, and OpenVPN for their fantastic software. Also, thanks to Justin Ellingwood at DigitalOcean with his HowTo guide for Ubuntu VPNs, which pointed me in the right direction for much of this.

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04
