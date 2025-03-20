#!/usr/bin/pwsh
<#
.SYNOPSIS
    Reports on disk sizes across all Azure subscriptions.
.DESCRIPTION
    This script generates a detailed report of all disk sizes (OS and data disks)
    across all Azure subscriptions that the user has access to.
    It exports the results to CSV files.
.PARAMETER OutputFolder
    The folder where CSV files will be saved. If not specified, creates a timestamped folder.
.EXAMPLE
    ./Get-AzureDiskReport.ps1
.EXAMPLE
    ./Get-AzureDiskReport.ps1 -OutputFolder "/Users/username/Reports"
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = ""
)

function Test-AzureConnection {
    try {
        Write-Host "Azure authentication required for disk reporting." -ForegroundColor Cyan
        Write-Host "Please log in to your Azure account..." -ForegroundColor Yellow
        
        # Always prompt for authentication
        Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
        Connect-AzAccount
        
        $context = Get-AzContext
        if ($null -eq $context.Account) {
            Write-Host "Login failed. Please run the script again." -ForegroundColor Red
            return $false
        }
        
        Write-Host "Successfully authenticated as $($context.Account.Id)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error during Azure authentication: $_" -ForegroundColor Red
        Write-Host "Please ensure the Az PowerShell module is installed. You can install it with:" -ForegroundColor Yellow
        Write-Host "Install-Module -Name Az -AllowClobber -Force" -ForegroundColor Yellow
        return $false
    }
}

function Get-AzureDiskReport {
    Write-Host "Azure Disk Size Report Generator" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan

    # Check if PowerShell Az module is installed
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-Host "The Az PowerShell module is not installed." -ForegroundColor Red
        Write-Host "Please install it with: Install-Module -Name Az -AllowClobber -Force" -ForegroundColor Yellow
        return
    }

    # Check if logged in
    if (-not (Test-AzureConnection)) {
        return
    }

    # Create output folder if not specified
    if ([string]::IsNullOrEmpty($OutputFolder)) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $OutputFolder = "AzureDiskReport_$timestamp"
    }

    if (-not (Test-Path -Path $OutputFolder)) {
        New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    }

    $detailedReportPath = Join-Path -Path $OutputFolder -ChildPath "AzureDisks_Detailed.csv"
    $summaryReportPath = Join-Path -Path $OutputFolder -ChildPath "AzureDisks_Summary.csv"

    # Arrays to store results
    $allDisks = @()
    $subscriptionTotals = @()
    $grandTotal = 0

    # Get all subscriptions
    Write-Host "Getting list of subscriptions..." -ForegroundColor Green
    $subscriptions = Get-AzSubscription

    foreach ($subscription in $subscriptions) {
        $subId = $subscription.Id
        $subName = $subscription.Name
        
        Write-Host "Processing subscription: $subName" -ForegroundColor Green
        
        # Set current subscription
        Set-AzContext -SubscriptionId $subId | Out-Null
        
        # Get all disks in the subscription
        Write-Host "  Getting disks..." -ForegroundColor Green
        $disks = Get-AzDisk
        
        $subTotalSize = 0
        
        foreach ($disk in $disks) {
            $diskSize = $disk.DiskSizeGB
            $subTotalSize += $diskSize
            
            # Determine if it's an OS disk or data disk
            $diskCategory = "Unattached"
            $vmName = ""
            
            if ($disk.ManagedBy) {
                $vmId = $disk.ManagedBy
                $vmName = $vmId.Split('/')[-1]
                $resourceGroupName = ($vmId -split '/resourceGroups/')[1].Split('/')[0]
                
                try {
                    $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction SilentlyContinue
                    if ($vm) {
                        if ($vm.StorageProfile.OsDisk.Name -eq $disk.Name) {
                            $diskCategory = "OS Disk"
                        }
                        else {
                            $diskCategory = "Data Disk"
                        }
                    }
                }
                catch {
                    Write-Host "    Warning: Couldn't determine disk type for $($disk.Name): $_" -ForegroundColor Yellow
                }
            }
            
            # Add to detailed report
            $diskInfo = [PSCustomObject]@{
                SubscriptionId = $subId
                SubscriptionName = $subName
                ResourceGroup = $disk.ResourceGroupName
                DiskName = $disk.Name
                DiskSizeGB = $diskSize
                DiskType = $disk.Sku.Name
                Location = $disk.Location
                Category = $diskCategory
                AttachedVM = $vmName
            }
            
            $allDisks += $diskInfo
        }
        
        # Add to subscription totals
        $subscriptionTotals += [PSCustomObject]@{
            SubscriptionId = $subId
            SubscriptionName = $subName
            TotalDiskSizeGB = $subTotalSize
        }
        
        $grandTotal += $subTotalSize
    }

    # Export detailed report
    Write-Host "Exporting detailed report to $detailedReportPath" -ForegroundColor Green
    $allDisks | Export-Csv -Path $detailedReportPath -NoTypeInformation

    # Export summary report
    Write-Host "Exporting summary report to $summaryReportPath" -ForegroundColor Green
    $subscriptionTotals | Export-Csv -Path $summaryReportPath -NoTypeInformation -Append
    
    # Add grand total to summary
    [PSCustomObject]@{
        SubscriptionId = "TOTAL"
        SubscriptionName = "All Subscriptions"
        TotalDiskSizeGB = $grandTotal
    } | Export-Csv -Path $summaryReportPath -NoTypeInformation -Append

    Write-Host "`nReport generation complete!" -ForegroundColor Cyan
    Write-Host "Detailed report: $detailedReportPath"
    Write-Host "Summary report: $summaryReportPath"
    Write-Host "`nTotal disk size across all subscriptions: $grandTotal GB"
}

# Run the report
Get-AzureDiskReport
