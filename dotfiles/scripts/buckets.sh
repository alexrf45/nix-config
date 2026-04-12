#!/usr/bin/env bash

for b in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
  if aws s3api get-bucket-policy-status --bucket $b \
    --query 'PolicyStatus.IsPublic' --output text | grep -q 'true'; then
    echo "$b is public"
  fi
done
