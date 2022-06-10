param (    
    $count = 1600,
    $applyThrottle = 10,
    $organizationName = "test-agents",
    $workspaceNamePrefix = "test-agents-",
    $terraformUrl = "tfe.hashicorpdemo.net",
    $terraformToken = ""
)

$ProgressPreference = 'SilentlyContinue'

if($terraformToken -eq "")
{
    $terraformToken = Get-Content -Path ./temptoken.txt -Raw
}

if(Test-Path -Path ./config.tar.gz)
{
    $result = Remove-Item -Path ./config.tar.gz -Force
}

tar -cvzf config.tar.gz -L main.tf

"Running Apply"
1..$count | ForEach-Object -Parallel { 
    $workspaceName = "$($using:workspaceNamePrefix)$($_.ToString("0000"))"; 
    $terraformUrl = $($using:terraformUrl)
    $terraformToken = $($using:terraformToken)
    $organizationName = $($using:organizationName)

    "Running terraform apply for $workspaceName"
    $workspace = Invoke-RestMethod -Uri "https://$($terraformUrl)/api/v2/organizations/$($organizationName)/workspaces/$($workspaceName)" -Headers @{
        "Authorization" = "Bearer $terraformToken"
    } -Method Get
    $workspaceId = $workspace.data.id
    
    $params = @{
        "data" = @{
            "type" = "confgiration-versions";
            "attributes" = @{
                "auto-queue-runs" = $true
            }
        }
    }
    $configurationVersion = Invoke-RestMethod -Uri "https://$($terraformUrl)/api/v2/workspaces/$($workspaceId)/configuration-versions" -Headers @{
        "Authorization" = "Bearer $terraformToken"
    } -Method Post -ContentType "application/vnd.api+json" -Body ($params | ConvertTo-Json)
    $uploadUrl = $configurationVersion.data.attributes."upload-url"
    
    Invoke-RestMethod -Uri $uploadUrl -Headers @{
        "Authorization" = "Bearer $terraformToken"
    } -Method Put -ContentType "application/octet-stream" -InFile ./config.tar.gz
} -ThrottleLimit $applyThrottle

