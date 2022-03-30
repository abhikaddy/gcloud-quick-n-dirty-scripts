#!/bin/bash

while getopts b: option
do
    case "${option}"
        in
        b)bucket=${OPTARG};;
    esac
done

# the user <ACCOUNT> must have these permission
# storage.buckets.get
# resourcemanager.projects.get on the bucket project
#gcloud auth login <ACCOUNT>

BUCKET_NAME=$bucket

ACCESS_TOKEN=$(gcloud auth print-access-token)

PROJECT_NUMBER=$(curl -s -H "Authorization: Bearer ${ACCESS_TOKEN}" https://storage.googleapis.com/storage/v1/b/${BUCKET_NAME} | jq -r .projectNumber)

#echo $PROJECT_NUMBER
gcloud projects list --filter="PROJECT_NUMBER=${PROJECT_NUMBER}" --format="value(PROJECT_ID, NAME)"

#Usage: ./script-get-project-from-bucket.sh -b "<bucket name>"
