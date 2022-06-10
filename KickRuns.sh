count=1600
applyThrottle=10
organizationName="test-agents"
workspaceNamePrefix="test-agents-"
terraformUrl="tfe.hashicorpdemo.net"
terraformToken=""

while getopts c:r:o:w:u:t: flag
do
    case "${flag}" in
        c) count=${OPTARG};;
        r) applyThrottle=${OPTARG};;
        o) organizationName=${OPTARG};;
        w) workspaceNamePrefix=${OPTARG};;
        u) terraformUrl=${OPTARG};;
        t) terraformToken=${OPTARG};;
    esac
done

if [[$terraformToken==""]]; then
    terraformToken=`cat ./temptoken.txt`
fi

rm -f ./config.tar.gz
tar -cvzf config.tar.gz -L main.tf

for i in $(seq -f "%04g" 1 $count); do
    workspaceName=$workspaceNamePrefix$i
    echo "Running terraform apply for $workspaceName"
    workspace=curl \
        --header "Authorization: Bearer $terraformToken" \
        --header "Content-Type: application/vnd.api+json" \
        "https://$($terraformUrl)/api/v2/organizations/$($organizationName)/workspaces/$($workspaceName)"
    workspaceId=workspace | jq -r '.data.id'
    
    params=<<EOF {
  "data": {
    "type": "configuration-versions",
    "attributes": {
      "auto-queue-runs": true
    }
  }
}
EOF

    configurationVersion=curl \
        --header "Authorization: Bearer $terraformToken" \
        --header "Content-Type: application/vnd.api+json" \
        --request POST \
        --data $params \
        "https://$($terraformUrl)/api/v2/workspaces/$($workspaceId)/configuration-versions"

    uploadUrl=configurationVersion | jq -r '.data.attributes.upload-url'
    
    curl \
        --header "Content-Type: application/octet-stream" \
        --request PUT \
        --data-binary ./config.tar.gz \
        $uploadUrl
done