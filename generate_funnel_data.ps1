# generate_funnel_data.ps1
# Enterprise Marketing Funnel Analytics Dataset Generator

$outputDir = "C:\Users\lenovo\.gemini\antigravity\scratch\marketing-funnel-dashboard"
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force }

Write-Host "Generating calibrated marketing funnel dataset..." -ForegroundColor Cyan

$campaigns = @(
    [PSCustomObject]@{ Id="CMP-001"; Name="Google Search - High Intent Core"; Channel="Google Ads"; Type="Search"; Spend=55000; Imp=480000; Clicks=22000; TargetACV=18000 },
    [PSCustomObject]@{ Id="CMP-002"; Name="Google Search - Competitor Conquesting"; Channel="Google Ads"; Type="Search"; Spend=32000; Imp=350000; Clicks=16500; TargetACV=15000 },
    [PSCustomObject]@{ Id="CMP-003"; Name="Google Display - Remarketing"; Channel="Google Ads"; Type="Display"; Spend=28000; Imp=1450000; Clicks=19500; TargetACV=12000 },
    [PSCustomObject]@{ Id="CMP-004"; Name="Meta - E-Book Lead Gen Forms"; Channel="Meta Ads"; Type="Social"; Spend=52000; Imp=2400000; Clicks=58000; TargetACV=3800 },
    [PSCustomObject]@{ Id="CMP-005"; Name="Meta - Lookalike Video Blitz"; Channel="Meta Ads"; Type="Social"; Spend=30000; Imp=1650000; Clicks=34000; TargetACV=4200 },
    [PSCustomObject]@{ Id="CMP-006"; Name="Meta - Retargeting Offer"; Channel="Meta Ads"; Type="Retargeting"; Spend=16000; Imp=750000; Clicks=12000; TargetACV=4800 },
    [PSCustomObject]@{ Id="CMP-007"; Name="LinkedIn - ABM Enterprise Decision Makers"; Channel="LinkedIn"; Type="ABM"; Spend=68000; Imp=420000; Clicks=10500; TargetACV=32000 },
    [PSCustomObject]@{ Id="CMP-008"; Name="LinkedIn - IT Leadership Inbound"; Channel="LinkedIn"; Type="Social"; Spend=44000; Imp=310000; Clicks=7800; TargetACV=26000 },
    [PSCustomObject]@{ Id="CMP-009"; Name="LinkedIn - Industry Benchmark Report"; Channel="LinkedIn"; Type="Content"; Spend=23000; Imp=220000; Clicks=5200; TargetACV=24000 },
    [PSCustomObject]@{ Id="CMP-010"; Name="Email - Product Update & Re-engage"; Channel="Email"; Type="Email"; Spend=14000; Imp=195000; Clicks=18000; TargetACV=14500 },
    [PSCustomObject]@{ Id="CMP-011"; Name="Email - Automated Lifecycle Drip"; Channel="Email"; Type="Email"; Spend=18000; Imp=265000; Clicks=24500; TargetACV=13500 },
    [PSCustomObject]@{ Id="CMP-012"; Name="Organic - Solution Comparison Hub"; Channel="Organic Search"; Type="Inbound"; Spend=25000; Imp=580000; Clicks=32000; TargetACV=19000 },
    [PSCustomObject]@{ Id="CMP-013"; Name="Organic - Technical Docs & Guides"; Channel="Organic Search"; Type="Inbound"; Spend=20000; Imp=440000; Clicks=21000; TargetACV=17500 },
    [PSCustomObject]@{ Id="CMP-014"; Name="Referral - Strategic Partner Network"; Channel="Referral"; Type="Partner"; Spend=15000; Imp=110000; Clicks=9500; TargetACV=28000 },
    [PSCustomObject]@{ Id="CMP-015"; Name="Referral - Customer Advocacy Program"; Channel="Referral"; Type="Advocacy"; Spend=10000; Imp=70000; Clicks=6500; TargetACV=22000 }
)

$channelProfiles = @{
    "Google Ads"     = @{ LeadShare=0.20; QualRate=0.42; OppRate=0.30; WinRate=0.28; BaseACV=16500; DefaultSeg="Mid-Market" }
    "Meta Ads"       = @{ LeadShare=0.38; QualRate=0.14; OppRate=0.12; WinRate=0.15; BaseACV=4200;  DefaultSeg="SMB" }
    "LinkedIn"       = @{ LeadShare=0.11; QualRate=0.68; OppRate=0.44; WinRate=0.32; BaseACV=28500; DefaultSeg="Enterprise" }
    "Email"          = @{ LeadShare=0.13; QualRate=0.54; OppRate=0.35; WinRate=0.24; BaseACV=14000; DefaultSeg="Mid-Market" }
    "Organic Search" = @{ LeadShare=0.11; QualRate=0.58; OppRate=0.38; WinRate=0.26; BaseACV=18200; DefaultSeg="Mid-Market" }
    "Referral"       = @{ LeadShare=0.07; QualRate=0.76; OppRate=0.52; WinRate=0.42; BaseACV=24500; DefaultSeg="Enterprise" }
}

$dropReasons = @{
    "Lead" = @("Invalid / Personal Email", "Job Seeker / Student", "Accidental Form Click", "Competitor Snooping", "Looking for Free Tier Only")
    "Qualified" = @("No Purchasing Budget", "Wrong ICP (Micro business)", "Indefinite Timeline (>12 mo)", "No Executive Sponsor", "Unreachable / Ghosted SDR")
    "Opportunity" = @("Chose Lower Cost Competitor", "Pricing & Commercial Terms", "Feature / Compliance Gap", "Internal Project Frozen", "Security / Legal Audit Blocked")
}

$months = @("2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06", "2026-07", "2026-08", "2026-09", "2026-10", "2026-11", "2026-12")

$firstNames = @("James", "Sarah", "Michael", "Emma", "David", "Emily", "Robert", "Jessica", "Daniel", "Laura", "William", "Olivia", "Alex", "Sophia", "Matthew", "Ava", "Christopher", "Mia", "Andrew", "Charlotte", "Ethan", "Amelia", "Ryan", "Chloe", "Kevin", "Harper", "Brian", "Evelyn", "Jason", "Abigail")
$lastNames = @("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson")
$companies = @("Apex Systems", "BluePeak Tech", "CloudScale Networks", "DataPulse Corp", "Elevate Global", "FinTrack Solutions", "Genix Health", "Hyperion Logic", "Innovatech Labs", "JumpScale Digital", "Kinetix Media", "Luminary Analytics", "Matrix Dynamics", "Nexus Retail", "OmniPoint Energy", "PulseSecure Software", "Quantum Logistics", "RevStream Commerce", "Summit Capital", "TerraFirma Bio", "Unified Cloud", "Vanguard Financial", "WaveFront Robotics", "Xcelerate Partners", "Zenith Industrial")

$totalTargetRecords = 12000
$records = [System.Collections.Generic.List[PSObject]]::new($totalTargetRecords)
$rand = [System.Random]::new(12345)

for ($i = 1; $i -le $totalTargetRecords; $i++) {
    $leadId = "LEAD-" + $i.ToString("D6")
    
    # Month selection showing surge in H2 (Months 7-12)
    $mRoll = $rand.NextDouble()
    if ($mRoll -lt 0.22) { $mIdx = $rand.Next(0, 4) } # Jan-Apr
    elseif ($mRoll -lt 0.52) { $mIdx = $rand.Next(4, 8) } # May-Aug
    else { $mIdx = $rand.Next(8, 12) } # Sep-Dec (Surge!)
    
    $monthStr = $months[$mIdx]
    $day = $rand.Next(1, 29)
    $createdDate = "$monthStr-" + $day.ToString("D2")
    
    # In H2, Meta Ads share expands dramatically (from 28% to 48% of incoming leads)
    $cRoll = $rand.NextDouble()
    if ($mIdx -ge 6) {
        if ($cRoll -lt 0.48) { $chanName = "Meta Ads" }
        elseif ($cRoll -lt 0.65) { $chanName = "Google Ads" }
        elseif ($cRoll -lt 0.74) { $chanName = "LinkedIn" }
        elseif ($cRoll -lt 0.85) { $chanName = "Email" }
        elseif ($cRoll -lt 0.94) { $chanName = "Organic Search" }
        else { $chanName = "Referral" }
    } else {
        if ($cRoll -lt 0.28) { $chanName = "Meta Ads" }
        elseif ($cRoll -lt 0.50) { $chanName = "Google Ads" }
        elseif ($cRoll -lt 0.64) { $chanName = "LinkedIn" }
        elseif ($cRoll -lt 0.78) { $chanName = "Email" }
        elseif ($cRoll -lt 0.90) { $chanName = "Organic Search" }
        else { $chanName = "Referral" }
    }
    
    $chanProf = $channelProfiles[$chanName]
    $matchingCamps = $campaigns | Where-Object { $_.Channel -eq $chanName }
    $camp = $matchingCamps[$rand.Next(0, $matchingCamps.Count)]
    
    # Geography
    $gRoll = $rand.NextDouble()
    if ($gRoll -lt 0.50) { $geo = "North America" }
    elseif ($gRoll -lt 0.78) { $geo = "EMEA" }
    elseif ($gRoll -lt 0.92) { $geo = "APAC" }
    else { $geo = "LATAM" }
    
    # Customer Segment
    $sRoll = $rand.NextDouble()
    if ($chanName -eq "Meta Ads") {
        if ($sRoll -lt 0.78) { $segment = "SMB" }
        elseif ($sRoll -lt 0.95) { $segment = "Mid-Market" }
        else { $segment = "Enterprise" }
    } elseif ($chanName -eq "LinkedIn") {
        if ($sRoll -lt 0.52) { $segment = "Enterprise" }
        elseif ($sRoll -lt 0.86) { $segment = "Mid-Market" }
        else { $segment = "SMB" }
    } elseif ($chanName -eq "Google Ads") {
        if ($sRoll -lt 0.32) { $segment = "Enterprise" }
        elseif ($sRoll -lt 0.70) { $segment = "Mid-Market" }
        else { $segment = "SMB" }
    } else {
        if ($sRoll -lt 0.38) { $segment = "Enterprise" }
        elseif ($sRoll -lt 0.72) { $segment = "Mid-Market" }
        else { $segment = "SMB" }
    }
    
    # Lead Score
    if ($chanName -eq "LinkedIn") { $score = $rand.Next(65, 99) }
    elseif ($chanName -eq "Referral") { $score = $rand.Next(72, 100) }
    elseif ($chanName -eq "Organic Search") { $score = $rand.Next(50, 92) }
    elseif ($chanName -eq "Email") { $score = $rand.Next(45, 88) }
    elseif ($chanName -eq "Google Ads") { $score = $rand.Next(38, 86) }
    else { $score = $rand.Next(12, 60) } # Meta Ads has very low score
    
    # Progression
    $isLead = 1
    $isQual = 0
    $isOpp = 0
    $isWon = 0
    $dealVal = 0
    $cycleDays = $rand.Next(4, 25)
    $stage = "Lead"
    $dropStage = "None"
    $dropReason = "None"
    
    # Qualification Probability
    $qRate = $chanProf.QualRate
    if ($segment -eq "Enterprise") { $qRate += 0.08 }
    elseif ($segment -eq "SMB") { $qRate -= 0.06 }
    if ($mIdx -ge 6) { $qRate *= 0.90 } # Late year degradation
    
    if ($rand.NextDouble() -lt $qRate) {
        $isQual = 1
        $stage = "Qualified Lead"
        $cycleDays += $rand.Next(6, 18)
        
        # Opportunity Probability
        $oRate = $chanProf.OppRate
        if ($segment -eq "Enterprise") { $oRate += 0.06 }
        if ($rand.NextDouble() -lt $oRate) {
            $isOpp = 1
            $stage = "Opportunity"
            $cycleDays += $rand.Next(12, 40)
            
            # Win Probability
            $wRate = $chanProf.WinRate
            if ($segment -eq "Enterprise") { $wRate += 0.04 }
            if ($rand.NextDouble() -lt $wRate) {
                $isWon = 1
                $stage = "Customer (Won)"
                $cycleDays += $rand.Next(8, 28)
                
                $baseACV = $camp.TargetACV
                if ($segment -eq "Enterprise") {
                    $dealVal = [Math]::Round($baseACV * (1.6 + $rand.NextDouble() * 1.2), 0)
                } elseif ($segment -eq "Mid-Market") {
                    $dealVal = [Math]::Round($baseACV * (0.85 + $rand.NextDouble() * 0.5), 0)
                } else {
                    $dealVal = [Math]::Round($baseACV * (0.4 + $rand.NextDouble() * 0.4), 0)
                }
            } else {
                $dropStage = "Opportunity -> Customer"
                $rList = $dropReasons["Opportunity"]
                $dropReason = $rList[$rand.Next(0, $rList.Count)]
            }
        } else {
            $dropStage = "Qualified -> Opportunity"
            $rList = $dropReasons["Qualified"]
            $dropReason = $rList[$rand.Next(0, $rList.Count)]
        }
    } else {
        $dropStage = "Lead -> Qualified"
        $rList = $dropReasons["Lead"]
        $dropReason = $rList[$rand.Next(0, $rList.Count)]
    }
    
    $cName = $firstNames[$rand.Next(0, $firstNames.Count)] + " " + $lastNames[$rand.Next(0, $lastNames.Count)]
    $comp = $companies[$rand.Next(0, $companies.Count)]
    
    $row = [PSCustomObject]@{
        Lead_ID = $leadId
        Contact_Name = $cName
        Company = $comp
        Campaign_ID = $camp.Id
        Campaign_Name = $camp.Name
        Campaign_Type = $camp.Type
        Channel = $chanName
        Geography = $geo
        Customer_Segment = $segment
        Created_Date = $createdDate
        Month = $monthStr
        Lead_Score = $score
        Stage_Reached = $stage
        Is_Lead = $isLead
        Is_Qualified = $isQual
        Is_Opportunity = $isOpp
        Is_Won = $isWon
        Deal_Value = $dealVal
        Sales_Cycle_Days = $cycleDays
        Drop_Off_Stage = $dropStage
        Drop_Off_Reason = $dropReason
    }
    $records.Add($row)
}

Write-Host "Exporting $($records.Count) records to CSV..." -ForegroundColor Green
$csvFile = Join-Path $outputDir "marketing_funnel_records.csv"
$records | Export-Csv -Path $csvFile -NoTypeInformation

# Calculate Totals
$totalSpend = 0
$totalImp = 0
$totalClicks = 0
foreach ($c in $campaigns) {
    $totalSpend += $c.Spend
    $totalImp += $c.Imp
    $totalClicks += $c.Clicks
}

$totalLeads = $records.Count
$totalQual = ($records | Where-Object { $_.Is_Qualified -eq 1 }).Count
$totalOpp = ($records | Where-Object { $_.Is_Opportunity -eq 1 }).Count
$totalWon = ($records | Where-Object { $_.Is_Won -eq 1 }).Count

$totalRev = 0
foreach ($r in $records) { $totalRev += $r.Deal_Value }

$convRate = [Math]::Round(($totalWon / $totalLeads) * 100, 2)
$avgRevCust = if ($totalWon -gt 0) { [Math]::Round($totalRev / $totalWon, 0) } else { 0 }
$cpl = [Math]::Round($totalSpend / $totalLeads, 2)
$cac = if ($totalWon -gt 0) { [Math]::Round($totalSpend / $totalWon, 2) } else { 0 }
$roi = [Math]::Round((($totalRev - $totalSpend) / $totalSpend) * 100, 1)
$ctr = [Math]::Round(($totalClicks / $totalImp) * 100, 2)

Write-Host "================== EXECUTIVE TOTALS ==================" -ForegroundColor Yellow
Write-Host "Total Spend: `$$totalSpend | Impressions: $totalImp | Clicks: $totalClicks | CTR: $ctr%"
Write-Host "Total Leads: $totalLeads | Qualified: $totalQual ($([Math]::Round(($totalQual/$totalLeads)*100,1))%)"
Write-Host "Opportunities: $totalOpp ($([Math]::Round(($totalOpp/$totalQual)*100,1))%) | Converted: $totalWon ($([Math]::Round(($totalWon/$totalOpp)*100,1))%)"
Write-Host "Overall Conv Rate: $convRate% | Revenue: `$$totalRev | Avg Deal: `$$avgRevCust"
Write-Host "CPL: `$$cpl | CAC: `$$cac | ROI: $roi%"
Write-Host "======================================================" -ForegroundColor Yellow

# Build Aggregated JSON for Instant Dashboard Loading
$campaignSummaryList = @()
foreach ($c in $campaigns) {
    $cLeads = ($records | Where-Object { $_.Campaign_ID -eq $c.Id }).Count
    $cQual = ($records | Where-Object { $_.Campaign_ID -eq $c.Id -and $_.Is_Qualified -eq 1 }).Count
    $cOpp = ($records | Where-Object { $_.Campaign_ID -eq $c.Id -and $_.Is_Opportunity -eq 1 }).Count
    $cWon = ($records | Where-Object { $_.Campaign_ID -eq $c.Id -and $_.Is_Won -eq 1 }).Count
    $cRev = 0
    foreach ($r in ($records | Where-Object { $_.Campaign_ID -eq $c.Id })) { $cRev += $r.Deal_Value }
    
    $cCtr = [Math]::Round(($c.Clicks / $c.Imp) * 100, 2)
    $cQualRate = if ($cLeads -gt 0) { [Math]::Round(($cQual / $cLeads) * 100, 1) } else { 0 }
    $cOppRate = if ($cQual -gt 0) { [Math]::Round(($cOpp / $cQual) * 100, 1) } else { 0 }
    $cConvRate = if ($cLeads -gt 0) { [Math]::Round(($cWon / $cLeads) * 100, 2) } else { 0 }
    $cCpl = if ($cLeads -gt 0) { [Math]::Round($c.Spend / $cLeads, 2) } else { 0 }
    $cCac = if ($cWon -gt 0) { [Math]::Round($c.Spend / $cWon, 2) } else { 0 }
    $cRoi = if ($c.Spend -gt 0) { [Math]::Round((($cRev - $c.Spend) / $c.Spend) * 100, 1) } else { 0 }
    
    $campaignSummaryList += [PSCustomObject]@{
        Id = $c.Id
        Name = $c.Name
        Channel = $c.Channel
        Type = $c.Type
        Impressions = $c.Imp
        Clicks = $c.Clicks
        CTR = $cCtr
        Spend = $c.Spend
        Leads = $cLeads
        QualifiedLeads = $cQual
        Opportunities = $cOpp
        Won = $cWon
        Revenue = $cRev
        QualRate = $cQualRate
        OppRate = $cOppRate
        ConvRate = $cConvRate
        CPL = $cCpl
        CAC = $cCac
        ROI = $cRoi
    }
}

$campCsvPath = Join-Path $outputDir "campaign_performance_summary.csv"
$campaignSummaryList | Export-Csv -Path $campCsvPath -NoTypeInformation

# Month by Month Trends
$monthlySummaryList = @()
foreach ($m in $months) {
    $mRecs = $records | Where-Object { $_.Month -eq $m }
    $mLeads = $mRecs.Count
    $mQual = ($mRecs | Where-Object { $_.Is_Qualified -eq 1 }).Count
    $mOpp = ($mRecs | Where-Object { $_.Is_Opportunity -eq 1 }).Count
    $mWon = ($mRecs | Where-Object { $_.Is_Won -eq 1 }).Count
    $mRev = 0
    foreach ($r in $mRecs) { $mRev += $r.Deal_Value }
    
    # Prorated monthly spend
    $mSpend = [Math]::Round($totalSpend / 12, 0)
    if ($m -in @("2026-09", "2026-10", "2026-11", "2026-12")) {
        $mSpend = [Math]::Round($mSpend * 1.35, 0)
    } elseif ($m -in @("2026-01", "2026-02", "2026-03")) {
        $mSpend = [Math]::Round($mSpend * 0.85, 0)
    }
    
    $monthlySummaryList += [PSCustomObject]@{
        Month = $m
        Leads = $mLeads
        QualifiedLeads = $mQual
        Opportunities = $mOpp
        Conversions = $mWon
        Revenue = $mRev
        MarketingSpend = $mSpend
        ConvRate = if ($mLeads -gt 0) { [Math]::Round(($mWon / $mLeads) * 100, 2) } else { 0 }
    }
}

$monthCsvPath = Join-Path $outputDir "monthly_funnel_trends.csv"
$monthlySummaryList | Export-Csv -Path $monthCsvPath -NoTypeInformation

# Write JavaScript bundle for zero-dependency local dashboard
$bundle = @{
    ExecutiveSummary = @{
        TotalImpressions = $totalImp
        TotalClicks = $totalClicks
        TotalLeads = $totalLeads
        QualifiedLeads = $totalQual
        Opportunities = $totalOpp
        ConvertedCustomers = $totalWon
        ConversionRate = $convRate
        TotalRevenue = $totalRev
        AverageRevenuePerCustomer = $avgRevCust
        CostPerLead = $cpl
        CustomerAcquisitionCost = $cac
        MarketingROI = $roi
        TotalSpend = $totalSpend
        CTR = $ctr
    }
    Campaigns = $campaignSummaryList
    MonthlyTrends = $monthlySummaryList
    Records = $records
}

$jsPath = Join-Path $outputDir "marketing_funnel_data.js"
$jsContent = "window.MARKETING_FUNNEL_DATA = " + ($bundle | ConvertTo-Json -Depth 6) + ";"
[System.IO.File]::WriteAllText($jsPath, $jsContent)

Write-Host "Data generation completely finished! CSV and JS bundle ready in: $outputDir" -ForegroundColor Green
