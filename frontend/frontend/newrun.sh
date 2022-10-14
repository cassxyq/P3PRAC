#rm -rf .terraform

terraform init  \
#The -input=false option prevents Terraform CLI from asking for user actions (it will throw an error if the input was required).

terraform plan input=false -out=tfplan.file \

terraform apply -auto-approve 