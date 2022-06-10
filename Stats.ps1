param (    
    $count = 1600,
    $organizationName = "test-agents",
    $workspaceNamePrefix = "test-agents-",
    $terraformUrl = "tfe.hashicorpdemo.net",
    $terraformToken = ""
)

if($terraformToken -eq "")
{
    $terraformToken = Get-Content -Path ./temptoken.txt -Raw
}

$agentPools = Invoke-RestMethod -Uri "https://$($terraformUrl)/api/v2/organizations/$($organizationName)/agent-pools" -Headers @{
    "Authorization" = "Bearer $terraformToken"
} -Method Get
$agentPoolId = $agentPools.data.id

$page = 1
$pageSize = 100
$agents = @()

$agentsPage = Invoke-RestMethod -Uri "https://$($terraformUrl)/api/v2/agent-pools/$($agentPoolId)/agents?page[number]=$($page)&page[size]=$($pageSize)" -Headers @{
    "Authorization" = "Bearer $terraformToken"
} -Method Get

$agents = $agents + $agentsPage.data
$totalPages = $agentsPage.meta.pagination."total-pages"
$totalAgents = $agentsPage.meta.pagination."total-count"
"Got page $page"
$page++
"Total agents: $totalAgents"

while($page -le $totalPages)
{
    $agentsPage = Invoke-RestMethod -Uri $agentsPage.links.next -Headers @{
        "Authorization" = "Bearer $terraformToken"
    } -Method Get

    $agents = $agents + $agentsPage.data

    "Got page $page"
    $page++
}

"Found agents: $($agents.Count)"

$filteredAgents = $agents | Where-Object{$_.attributes.status -ne "exited"}
$filteredAgents = $filteredAgents | Sort-Object -Property id
"Running and queued agents count: $filteredAgents.Count"

$runningAgents = $filteredAgents | Where-Object{$_.attributes.status -eq "running"}
"Running agents count: $runningAgents.Count"

$queuedAgents = $filteredAgents | Where-Object{$_.attributes.status -eq "queued"}
"Queued agents count: $queuedAgents.Count"

# NOTE: There appears to be an issue related to ordering with this API call (https://www.terraform.io/cloud-docs/api-docs/agents#list-agents). 
# This results in duplicate records being outputted due to amount of time it takes to page thorugh the results and the limit of 100 results per page. This needs further investigation.
$duplicateCount = 0
$duplicates = @()

foreach($agent in $filteredAgents)
{
    $agentId = $agent.id
    
    if(-not ($duplicates -contains $agentId))
    {
        $test = $agents | Where-Object{$_.id -eq $agentId}

        if($test.Count -gt 1)
        {
            "Found duplicate agent: $agentId"
            $test
            $duplicateCount++
            $duplicates += $agentId
        }
    }
}

"Duplicate agent records: $duplicateCount"