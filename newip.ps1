terraform taint aws_instance.vpn
terraform plan   -var-file="secure.tfvars"   -var-file="newipeveryday.tfvars"
terraform apply   -var-file="secure.tfvars"   -var-file="newipeveryday.tfvars" -auto-approve
