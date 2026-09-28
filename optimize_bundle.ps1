# optimize_bundle.ps1
$dashboardDir = "C:\Users\lenovo\.gemini\antigravity\scratch\marketing-funnel-dashboard"
$recordsCsv = Import-Csv -Path (Join-Path $dashboardDir "marketing_funnel_records.csv")
$campCsv = Import-Csv -Path (Join-Path $dashboardDir "campaign_performance_summary.csv")
$monthCsv = Import-Csv -Path (Join-Path $dashboardDir "monthly_funnel_trends.csv")

Write-Host "Compacting data bundle for maximum browser performance..." -ForegroundColor Cyan

# Pre-aggregate dimensions for rapid multi-dimensional slicing
$byChannel = @{}
$bySegment = @{}
$byGeo = @{}
$byDropReason = @{}

foreach ($r in $recordsCsv) {
    # Channel
    $ch = $r.Channel
    if (-not $byChannel.ContainsKey($ch)) {
        $byChannel[$ch] = @{ Leads=0; Qual=0; Opp=0; Won=0; Rev=0; TotalScore=0 }
    }
    $byChannel[$ch].Leads++
    if ($r.Is_Qualified -eq "1") { $byChannel[$ch].Qual++ }
    if ($r.Is_Opportunity -eq "1") { $byChannel[$ch].Opp++ }
    if ($r.Is_Won -eq "1") { $byChannel[$ch].Won++; $byChannel[$ch].Rev += [double]$r.Deal_Value }
    $byChannel[$ch].TotalScore += [int]$r.Lead_Score
    
    # Segment
    $sg = $r.Customer_Segment
    if (-not $bySegment.ContainsKey($sg)) {
        $bySegment[$sg] = @{ Leads=0; Qual=0; Opp=0; Won=0; Rev=0 }
    }
    $bySegment[$sg].Leads++
    if ($r.Is_Qualified -eq "1") { $bySegment[$sg].Qual++ }
    if ($r.Is_Opportunity -eq "1") { $bySegment[$sg].Opp++ }
    if ($r.Is_Won -eq "1") { $bySegment[$sg].Won++; $bySegment[$sg].Rev += [double]$r.Deal_Value }

    # Geo
    $g = $r.Geography
    if (-not $byGeo.ContainsKey($g)) {
        $byGeo[$g] = @{ Leads=0; Qual=0; Opp=0; Won=0; Rev=0 }
    }
    $byGeo[$g].Leads++
    if ($r.Is_Qualified -eq "1") { $byGeo[$g].Qual++ }
    if ($r.Is_Opportunity -eq "1") { $byGeo[$g].Opp++ }
    if ($r.Is_Won -eq "1") { $byGeo[$g].Won++; $byGeo[$g].Rev += [double]$r.Deal_Value }

    # Drop Reasons
    if ($r.Drop_Off_Reason -ne "None") {
        $dr = $r.Drop_Off_Reason
        if (-not $byDropReason.ContainsKey($dr)) { $byDropReason[$dr] = 0 }
        $byDropReason[$dr]++
    }
}

# Compact row tuples for high-speed client-side filtering:
# [0:Lead_ID, 1:Company, 2:Campaign_ID, 3:Channel, 4:Geography, 5:Customer_Segment, 6:Month, 7:Lead_Score, 8:Stage_Reached, 9:Is_Lead, 10:Is_Qualified, 11:Is_Opportunity, 12:Is_Won, 13:Deal_Value, 14:Sales_Cycle_Days, 15:Drop_Off_Stage, 16:Drop_Off_Reason]
$compactRows = [System.Collections.Generic.List[object]]::new()
foreach ($r in $recordsCsv) {
    $compactRows.Add(@(
        $r.Lead_ID,
        $r.Company,
        $r.Campaign_ID,
        $r.Channel,
        $r.Geography,
        $r.Customer_Segment,
        $r.Month,
        [int]$r.Lead_Score,
        $r.Stage_Reached,
        [int]$r.Is_Lead,
        [int]$r.Is_Qualified,
        [int]$r.Is_Opportunity,
        [int]$r.Is_Won,
        [double]$r.Deal_Value,
        [int]$r.Sales_Cycle_Days,
        $r.Drop_Off_Stage,
        $r.Drop_Off_Reason
    ))
}

$payload = @{
    Columns = @("Lead_ID", "Company", "Campaign_ID", "Channel", "Geography", "Customer_Segment", "Month", "Lead_Score", "Stage_Reached", "Is_Lead", "Is_Qualified", "Is_Opportunity", "Is_Won", "Deal_Value", "Sales_Cycle_Days", "Drop_Off_Stage", "Drop_Off_Reason")
    Campaigns = $campCsv
    MonthlyTrends = $monthCsv
    Aggregates = @{
        ByChannel = $byChannel
        BySegment = $bySegment
        ByGeo = $byGeo
        ByDropReason = $byDropReason
    }
    Rows = $compactRows
}

$jsText = "window.MARKETING_FUNNEL_DATA = " + ($payload | ConvertTo-Json -Depth 6 -Compress) + ";"
[System.IO.File]::WriteAllText((Join-Path $dashboardDir "marketing_funnel_data.js"), $jsText)
Write-Host "Optimized marketing_funnel_data.js created successfully! Size reduced to $([Math]::Round((Get-Item (Join-Path $dashboardDir 'marketing_funnel_data.js')).Length / 1MB, 2)) MB" -ForegroundColor Green
