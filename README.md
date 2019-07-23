The NewIPEveryday tool requires a secure.tfvars file to draw information for the Cloud account being provisioned. To protect this information you should create a file in the repo directory called `.gitignore`. It should contain the following entries 

secure.tfvars  
*.ovpn  
*.pem  

Alternatively, this tool can be edited so that sensitive vars are read from the command line.

Instructions:

1. Install Git on your computer. Clone this repo to your local computer.

2. Install OpenVPN. 

3. Open OpenVPN settings. Click on `Advanced` tab. Enter the path to the downloaded repo where it says 'Folder:'. Click OK.

4. In the AWS console, create a key pair to use. Save the .pem for your public key to the repo directory and add it to your .gitignore file.

5. In the AWS console, create an IAM user with the ability to edit security groups, create instances, and destroy instances.

6. Create a file in the downloaded repo called 'secure.tfvars'. It should contain the following.

        local_ip       = YOUR external IP address  
        access_key     = Access key for IAM user you created  
        secret_key     = Secret key for IAM user you created  
        private_key    = NAME of the private key you created  
7. Install Terraform.

8. Run the following commands from the cloned directory.

        terraform taint aws_instance.vpn  
        terraform plan   -var-file="secure.tfvars"   -var-file="newipeveryday.tfvars"  
        terraform apply   -var-file="secure.tfvars"   -var-file="newipeveryday.tfvars"  
   (Admittedly, this can be improved)

9. Open OpenVPN. Right click the OpenVPN icon in your toolbar, and click `Connect`.

You should be connected to your own, secure VPN. Your IP address will be from somewhere in `us-east-1` unless you've changed your region in `tfvpn.tfvars`. To get a new IP address simply run the above commands again.

Shoutouts to the great people at Hashicorp, Ansible, and OpenVPN for their fantastic software. Also, thanks to Justin Ellingwood at DigitalOcean with his HowTo guide for Ubuntu VPNs, which pointed me in the right direction for much of this.

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04

Copyright (C) 2019 Michael Gombos. 