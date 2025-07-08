
# Azure Disk Snapshot Scripts

This repository contains scripts for creating snapshots of Azure managed disks in bulk.

## Scripts

### azure-disk-snapshot.sh
A bash script that uses Azure CLI to create snapshots of specific Azure managed disks.

## Features

- **Targeted Disk Selection**: Creates snapshots only for specified data disks
- **Automatic Naming**: Appends "-snapshot" to the original disk name
- **Error Handling**: Checks for disk existence before creating snapshots
- **Progress Tracking**: Shows real-time status of each snapshot operation
- **Summary Report**: Displays success/failure counts and lists all snapshots
- **Subscription Management**: Automatically sets the correct Azure subscription

## Prerequisites

- **Azure CLI**: Install using `brew install azure-cli`
- **Azure Account**: Valid Azure subscription with appropriate permissions
- **Disk Management Permissions**: Contributor or higher role on the resource group

## Configuration

Before running the script, update these variables in `azure-disk-snapshot.sh`:

```bash
SUBSCRIPTION_NAME="your-subscription-name"
RESOURCE_GROUP="your-resource-group-name"
LOCATION="your-azure-region"
```

## Usage

### 1. Install Azure CLI
```bash
brew install azure-cli
```

### 2. Login to Azure
```bash
az login
```

### 3. Make the script executable
```bash
chmod +x azure-disk-snapshot.sh
```

### 4. Run the script
```bash
./azure-disk-snapshot.sh
```

## Target Disks

The script is configured to create snapshots for the following example disks:
- my-backupvg-Disk01
- my-logarch_vg-Disk01
- my-logdir_vg-Disk01
- my-sapdata1_vg-Disk01
- my-sapdata2_vg-Disk01


## Output

The script provides:
- ✅ Success indicators for completed snapshots
- ❌ Error messages for failed operations
- 📊 Summary report with counts
- 📋 List of all snapshots in the resource group

## Example Output

```
Starting Azure disk snapshot process...
✓ Successfully set subscription to: usi-sandbox-sub
Found 13 disks to process

Processing disk: usil800-backupvg-Disk01
✓ Disk found: usil800-backupvg-Disk01
✓ Successfully created snapshot: usil800-backupvg-Disk01-snapshot

=== SNAPSHOT CREATION SUMMARY ===
Successful snapshots: 13
Failed snapshots: 0
Total disks processed: 13
```

## Troubleshooting

### Common Issues

1. **Authentication Error**
   ```bash
   az login
   ```

2. **Subscription Not Found**
   - Check available subscriptions: `az account list --output table`
   - Update the `SUBSCRIPTION_NAME` variable

3. **Resource Group Not Found**
   - Verify resource group name: `az group list --output table`
   - Update the `RESOURCE_GROUP` variable

4. **Permission Denied**
   - Ensure you have Contributor role on the resource group
   - Contact your Azure administrator

### Verification

Check created snapshots:
```bash
az snapshot list --resource-group "your-resource-group" --output table
```

## Notes

- Snapshots are created in the same resource group as the source disks
- Snapshot type is set to "Full" (incremental snapshots can be configured if needed)
- All configurations use Azure default settings
- The script skips disks that don't exist and continues with available ones

## Contributing

Feel free to submit issues and pull requests to improve the script.

## License

This project is open source and available under the MIT License.
