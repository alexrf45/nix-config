set -e

aws s3api delete-objects --bucket $1 \
  --delete "$(aws s3api list-object-versions --bucket $1 --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

aws s3api delete-objects --bucket $1 \
  --delete "$(aws s3api list-object-versions --bucket $1 --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"

aws s3api delete-bucket --bucket $1
