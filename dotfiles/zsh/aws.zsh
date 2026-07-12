#aws cli aliases — credentials injected via 1Password CLI plugin
alias aws='op plugin run -- aws'

# Switch AWS profile: `awsp personal` or `awsp default`
awsp() {
  export AWS_PROFILE="${1:-default}"
  echo "Switched to AWS profile: $AWS_PROFILE"
}
alias ec2-check='op plugin run -- aws ec2 describe-instances --query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType,Status:State.Name,VpcId:VpcId,Id:InstanceId}" --filters "Name=instance-state-name,Values=running" --output table'
alias s3-list="op plugin run -- aws s3api list-buckets | jq -r '.Buckets[].Name'"
alias vpc-check='op plugin run -- aws ec2 --output text --query "Vpcs[*].{VpcId:VpcId,Name:Tags[?Key=='Environment'].Value|[0],CidrBlock:CidrBlock}" describe-vpcs'
alias s3-delete='op plugin run -- aws s3api delete-bucket --bucket ${BUCKET}'
alias iam-access-id-admin='op plugin run -- aws iam get-user --user-name account-admin | jq -r ".User | .UserId"'
#cloud-nuke aws
alias aws-nuke='cloud-nuke aws --exclude-resource-type s3 --exclude-resource-type iam --exclude-resource-type secretsmanager --exclude-resource-type dynamodb'
alias aws-inspect='cloud-nuke inspect-aws'

alias aws-services-list='~/.config/scripts/./services.sh'
alias aws-services-cost='~/.config/scripts/service-cost.sh'
alias aws-current-cost='~/.config/scripts/awscurrentcost.sh'
alias aws-cost-overall='~/.config/scripts/awscost.sh'
alias s3-backend-delete='~/.config/scripts/./s3-delete.sh'
alias s3-file-list="op plugin run -- aws s3api list-objects --query 'Contents[].Key' --output text"
alias ami-search='op plugin run -- aws ec2 describe-images --owner self amazon --filters "Name=architecture,Values=x86_64" "Name=name,Values=ubuntu/images/hvm-ssd/*" "Name=root-device-type,Values=ebs" --output table'
alias s3-create='python3 ~/.config/scripts/s3.py'
