#!/bin/bash

# Azure Disk Snapshot Script using Azure CLI
# This script creates snapshots for specific data disks

# Set variables
SUBSCRIPTION_NAME="my-sandbox-sub"
RESOURCE_GROUP="my-sandbox-cc-sub"
LOCATION="canadacentral"  # Azure region for Canada Central (lowercase, no spaces)

# Define the specific data disks to snapshot
TARGET_DISKS=(
    "my-backupvg-Disk01"
    "my-logarch_vg-Disk01"
    "my-logdir_vg-Disk01"
    "my-sapdata1_vg-Disk01"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Azure disk snapshot process...${NC}"

# Check if Azure CLI is installed and logged in
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    echo "Install: brew install azure-cli"
    exit 1
fi

# Check if logged in and set subscription
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}You are not logged in to Azure. Please run: az login${NC}"
    exit 1
fi

# Set the subscription
echo -e "${GREEN}Setting subscription to: $SUBSCRIPTION_NAME${NC}"
if az account set --subscription "$SUBSCRIPTION_NAME"; then
    echo -e "${GREEN}✓ Successfully set subscription to: $SUBSCRIPTION_NAME${NC}"
else
    echo -e "${RED}✗ Failed to set subscription. Please check subscription name.${NC}"
    echo -e "${YELLOW}Available subscriptions:${NC}"
    az account list --query "[].{Name:name, SubscriptionId:id}" --output table
    exit 1
fi

echo -e "${GREEN}Found ${#TARGET_DISKS[@]} disks to process${NC}"

# Counter for successful snapshots
SUCCESS_COUNT=0
FAILED_COUNT=0

# Loop through each disk and create snapshot
for DISK_NAME in "${TARGET_DISKS[@]}"; do
    SNAPSHOT_NAME="${DISK_NAME}-snapshot"
    
    echo -e "${CYAN}Processing disk: $DISK_NAME${NC}"
    
    # Check if disk exists
    if az disk show --resource-group "$RESOURCE_GROUP" --name "$DISK_NAME" --output none 2>/dev/null; then
        echo -e "${GREEN}✓ Disk found: $DISK_NAME${NC}"
        
        # Create snapshot
        if az snapshot create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$SNAPSHOT_NAME" \
            --source "$DISK_NAME" \
            --location "$LOCATION" \
            --output none 2>/dev/null; then
            
            echo -e "${GREEN}✓ Successfully created snapshot: $SNAPSHOT_NAME${NC}"
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}✗ Failed to create snapshot for disk: $DISK_NAME${NC}"
            ((FAILED_COUNT++))
        fi
    else
        echo -e "${RED}✗ Disk not found: $DISK_NAME${NC}"
        ((FAILED_COUNT++))
    fi
    
    echo "" # Empty line for readability
done

# Summary
echo -e "${GREEN}=== SNAPSHOT CREATION SUMMARY ===${NC}"
echo -e "${GREEN}Successful snapshots: $SUCCESS_COUNT${NC}"
echo -e "${RED}Failed snapshots: $FAILED_COUNT${NC}"
echo -e "${GREEN}Total disks processed: ${#TARGET_DISKS[@]}${NC}"

# Optional: List all snapshots in the resource group
echo -e "${YELLOW}Current snapshots in resource group:${NC}"
az snapshot list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, Status:provisioningState}" --output table

echo -e "${GREEN}Snapshot creation process completed!${NC}"
