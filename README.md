# Azure Disk Size Reporter

A PowerShell script that generates comprehensive reports on disk sizes across all your Azure subscriptions. The tool provides detailed information about OS disks, data disks, and unattached disks, exporting results to CSV files for easy analysis.

## Features

- **Cross-subscription reporting**: Analyzes all disks across all Azure subscriptions you have access to
- **Complete disk information**: Captures disk name, size, type, location, and attached VM details
- **Disk categorization**: Identifies OS disks, data disks, and unattached disks
- **CSV exports**: Generates both detailed and summary reports in CSV format
- **Fresh authentication**: Always prompts for Azure authentication to ensure proper access
- **Cross-platform compatibility**: Works on Windows, macOS, and Linux with PowerShell Core

## Prerequisites

- PowerShell Core (PowerShell 7.x or newer)
- Azure PowerShell Module (Az)
- Azure subscription access

## Installation

### macOS

1. Install PowerShell Core:
   ```bash
   brew install --cask powershell
   ```

2. Install the Azure PowerShell module:
   ```powershell
   pwsh -Command "Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser"
   ```

### Windows

1. Make sure you have PowerShell 5.1 or newer (already included in Windows 10 and 11)
2. For best results, install PowerShell 7:
   ```powershell
   winget install Microsoft.PowerShell
   ```

3. Install the Azure PowerShell module:
   ```powershell
   Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
   ```

### Linux

1. Install PowerShell Core following the [official documentation](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux)

2. Install the Azure PowerShell module:
   ```powershell
   pwsh -Command "Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser"
   ```

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/azure-disk-reporter.git
   cd azure-disk-reporter
   ```

2. Make the script executable (macOS/Linux only):
   ```bash
   chmod +x Get-AzureDiskReport.ps1
   ```

3. Run the script:
   - On Windows:
     ```powershell
     .\Get-AzureDiskReport.ps1
     ```
   - On macOS/Linux:
     ```bash
     pwsh ./Get-AzureDiskReport.ps1
     ```

4. Authenticate with your Azure account when prompted

5. Wait for the script to collect disk information and generate reports

### Command-line Parameters

The script accepts the following parameters:

- `-OutputFolder`: Specify a custom location for the CSV output files
  ```powershell
  .\Get-AzureDiskReport.ps1 -OutputFolder "C:\Reports\AzureDisks"
  ```
  or
  ```bash
  pwsh ./Get-AzureDiskReport.ps1 -OutputFolder "/Users/username/Reports"
  ```

## Output Files

The script generates two CSV files:

1. **AzureDisks_Detailed.csv**: Contains detailed information about each disk, including:
   - Subscription ID and name
   - Resource group
   - Disk name, size, type, and location
   - Disk category (OS Disk, Data Disk, or Unattached)
   - Attached VM name (if applicable)

2. **AzureDisks_Summary.csv**: Contains summary information, including:
   - Total disk size per subscription
   - Grand total across all subscriptions

## Example Output

### Detailed Report (AzureDisks_Detailed.csv)
```
SubscriptionId,SubscriptionName,ResourceGroup,DiskName,DiskSizeGB,DiskType,Location,Category,AttachedVM
00000000-0000-0000-0000-000000000000,Production,rg-prod-vm,prod-vm-osdisk,128,Premium_LRS,eastus,OS Disk,prod-vm
00000000-0000-0000-0000-000000000000,Production,rg-prod-vm,prod-vm-datadisk1,1024,Premium_LRS,eastus,Data Disk,prod-vm
00000000-0000-0000-0000-000000000000,Production,rg-prod-vm,backup-disk,512,Standard_LRS,eastus,Unattached,
11111111-1111-1111-1111-111111111111,Development,rg-dev-vm,dev-vm-osdisk,64,Standard_LRS,westus,OS Disk,dev-vm
```

### Summary Report (AzureDisks_Summary.csv)
```
SubscriptionId,SubscriptionName,TotalDiskSizeGB
00000000-0000-0000-0000-000000000000,Production,1664
11111111-1111-1111-1111-111111111111,Development,64
TOTAL,All Subscriptions,1728
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This script is provided as-is with no warranties. Always test in a non-production environment first.
