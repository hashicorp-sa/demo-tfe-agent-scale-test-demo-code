#!/bin/bash

count=1600
organizationName="test-agents"
workspaceNamePrefix="test-agents-"
terraformUrl="tfe.hashicorpdemo.net"
terraformToken=""
runDuration="300s"

while getopts c:r:o:w:u:t:r: flag
do
    case "${flag}" in
        c) count=${OPTARG};;
        o) organizationName=${OPTARG};;
        w) workspaceNamePrefix=${OPTARG};;
        u) terraformUrl=${OPTARG};;
        t) terraformToken=${OPTARG};;
        r) runDuration=${OPTARG};;
    esac
done

if [[ -z $terraformToken ]]; then
    terraformToken=`cat ./temptoken.txt`
fi

cp ./main.tf ./main_test.tf
sed -i '' -e "s/30s/$runDuration/" ./main_test.tf

rm -f ./config.tar.gz
tar -cvzf config.tar.gz -L main_test.tf

for i in $(seq -f "%04g" 1 $count); do
    workspaceName=$workspaceNamePrefix$i
    echo "Running terraform apply for $workspaceName"
    workspace=$(curl \
      --header "Authorization: Bearer $terraformToken" \
      --header "Content-Type: application/vnd.api+json" \
      "https://$terraformUrl/api/v2/organizations/$organizationName/workspaces/$workspaceName")

    workspaceId=$(echo $workspace | jq -r '.data.id')
    
    configurationVersion=$(curl \
      --header "Authorization: Bearer $terraformToken" \
      --header "Content-Type: application/vnd.api+json" \
      --request POST \
      --data-binary "{ \"data\": { \"type\": \"configuration-versions\", \"attributes\": { \"auto-queue-runs\": true } } }" \
      "https://$terraformUrl/api/v2/workspaces/$workspaceId/configuration-versions")

    uploadUrl=$(echo $configurationVersion | jq -r '.data.attributes."upload-url"')
    
    curl \
      --header "Content-Type: application/octet-stream" \
      --request PUT \
      --data-binary "@config.tar.gz" \
      $uploadUrl
done