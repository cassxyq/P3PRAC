rm -rf .terraform
terraform init
terraform fmt
terraform apply -auto-approve