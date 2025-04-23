#!/bin/bash
# filepath: /Users/charliehowlett/Documents/mdm-removal-script/MDM-Remove-Host.sh

echo "===== CheckRa1n MDM Removal Tool ====="
echo "This script will:"
echo "1. Install brew, sshpass and usbmuxd on your macOS host"
echo "2. Launch checkra1n.app to jailbreak the device"
echo "3. SSH into your device over USB"
echo "4. Execute the MDM removal commands directly"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install usbmuxd if not already installed
if ! brew list usbmuxd &> /dev/null; then
    echo "Installing usbmuxd..."
    brew install usbmuxd
else
    echo "usbmuxd is already installed."
fi

# Install sshpass if not already installed
if ! brew list sshpass &> /dev/null; then
    echo "Installing sshpass..."
    brew install hudochenkov/sshpass/sshpass
else
    echo "sshpass is already installed."
fi

# Check if checkra1n.app exists
if [ ! -d "/Applications/checkra1n.app" ] && [ ! -d "$HOME/Applications/checkra1n.app" ]; then
    echo "Error: checkra1n.app not found. Please install it from https://checkra.in"
    echo "and place it in your Applications folder."
    exit 1
fi

# Variables
DEVICE_IP="127.0.0.1"  # Default IP for USB tethering
DEVICE_PORT="2222"     # Default SSH port
DEVICE_USER="root"     # Default user for jailbroken iOS devices
DEVICE_PASS="alpine"   # Default password for jailbroken iOS devices
TARGET_DIR="/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles"

# Launch checkra1n.app to jailbreak the device
echo "Launching checkra1n..."
echo "Please follow the on-screen instructions to jailbreak your device."

# Try both potential locations for checkra1n.app
if [ -d "/Applications/checkra1n.app" ]; then
    open "/Applications/checkra1n.app"
else
    open "$HOME/Applications/checkra1n.app"
fi

echo "Please wait until checkra1n has started. If you are already in a jailbroken state, close checkra1n, then press Enter to continue..."
read -p ""

# Wait for device to reboot and finish jailbreak process
echo "Waiting for device to complete jailbreak process..."

# Kill any existing iproxy processes
pkill -f iproxy

# Run iproxy in background and suppress output
echo "Starting USB tunnel with iproxy..."
iproxy "$DEVICE_PORT" 44 > /dev/null 2>&1 &
IPROXY_PID=$!

# Store the PID so we can kill it later
echo "iproxy started with PID: $IPROXY_PID"

# Give iproxy a moment to start
sleep 2

# Check if iproxy is running
if ! ps -p $IPROXY_PID > /dev/null; then
    echo "Error: Failed to start iproxy. Please check your usbmuxd installation."
    exit 1
fi

echo "USB tunnel established. Attempting to connect to device..."

# Wait for SSH to be available
echo "Checking SSH connection to device... We will retry up to $MAX_RETRIES times. This should allow for the device to finish booting."
MAX_RETRIES=30
COUNT=0

while ! ping -c 1 -W 1 "$DEVICE_IP" &> /dev/null; do
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "Error: Could not reach device over the USB tunnel."
        exit 1
    fi
    echo "Waiting for device to be reachable... ($((COUNT+1))/$MAX_RETRIES)"
    COUNT=$((COUNT+1))
    sleep 3
done

# Test SSH connection
echo "Testing SSH connection..."
sshpass -p "$DEVICE_PASS" ssh -p 2222 -o StrictHostKeyChecking=no -T "$DEVICE_USER@$DEVICE_IP" "echo Connection successful" || {
    echo "Error: SSH connection failed."
    exit 1
}

# Execute the MDM removal directly over SSH
echo "Executing MDM removal commands..."
sshpass -p "$DEVICE_PASS" ssh -p 2222 -o StrictHostKeyChecking=no -T "$DEVICE_USER@$DEVICE_IP" << 'EOF'
echo "Starting MDM removal process..."

# Define target directory
TARGET_DIR="/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles"

# Remove existing configuration files
echo "Removing existing configuration files..."
rm -rf "$TARGET_DIR/CloudConfigurationDetails.plist"
rm -rf "$TARGET_DIR/CloudConfigurationSetAsideDetails.plist"

# Create configuration files directly
echo "Creating configuration files..."

# Create XML plist files for both configurations
cat > "$TARGET_DIR/CloudConfigurationDetails.plist" << 'EOFINNER'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ConfigurationWasApplied</key>
    <true/>
    <key>CloudConfigurationUIComplete</key>
    <true/>
    <key>PostSetupProfileWasInstalled</key>
    <true/>
    <key>AllowPairing</key>
    <true/>
    <key>AutoAdvanceSetup</key>
    <false/>
    <key>AwaitDeviceConfigured</key>
    <false/>
    <key>ConfigurationSource</key>
    <integer>0</integer>
    <key>ConfigurationURL</key>
    <string></string>
    <key>IsMDMUnremovable</key>
    <integer>0</integer>
    <key>IsMandatory</key>
    <false/>
    <key>IsMultiUser</key>
    <false/>
    <key>IsSupervised</key>
    <false/>
    <key>OrganizationAddress</key>
    <string>N/A</string>
    <key>OrganizationAddressLine1</key>
    <string>N/A</string>
    <key>OrganizationAddressLine2</key>
    <string>N/A</string>
    <key>OrganizationCity</key>
    <string>N/A</string>
    <key>OrganizationCountry</key>
    <string>N/A</string>
    <key>OrganizationDepartment</key>
    <string>N/A</string>
    <key>OrganizationEmail</key>
    <string>noreply@localhost.localdomain</string>
    <key>OrganizationMagic</key>
    <string></string>
    <key>OrganizationName</key>
    <string>Skip this step</string>
    <key>OrganizationPhone</key>
    <string>N/A</string>
    <key>OrganizationSupportPhone</key>
    <string>N/A</string>
    <key>OrganizationZipCode</key>
    <string>N/A</string>
    <key>SkipSetup</key>
    <array/>
    <key>SupervisorHostCertificates</key>
    <array/>
</dict>
</plist>
EOFINNER

# Create CloudConfigurationSetAsideDetails.plist - using the same format
cat > "$TARGET_DIR/CloudConfigurationSetAsideDetails.plist" << 'EOFINNER'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ConfigurationWasApplied</key>
    <true/>
    <key>CloudConfigurationUIComplete</key>
    <true/>
    <key>PostSetupProfileWasInstalled</key>
    <true/>
    <key>AllowPairing</key>
    <true/>
    <key>AutoAdvanceSetup</key>
    <false/>
    <key>AwaitDeviceConfigured</key>
    <false/>
    <key>ConfigurationSource</key>
    <integer>0</integer>
    <key>ConfigurationURL</key>
    <string></string>
    <key>IsMDMUnremovable</key>
    <integer>0</integer>
    <key>IsMandatory</key>
    <false/>
    <key>IsMultiUser</key>
    <false/>
    <key>IsSupervised</key>
    <false/>
    <key>OrganizationAddress</key>
    <string>N/A</string>
    <key>OrganizationAddressLine1</key>
    <string>N/A</string>
    <key>OrganizationAddressLine2</key>
    <string>N/A</string>
    <key>OrganizationCity</key>
    <string>N/A</string>
    <key>OrganizationCountry</key>
    <string>N/A</string>
    <key>OrganizationDepartment</key>
    <string>N/A</string>
    <key>OrganizationEmail</key>
    <string>noreply@localhost.localdomain</string>
    <key>OrganizationMagic</key>
    <string></string>
    <key>OrganizationName</key>
    <string>Skip this step</string>
    <key>OrganizationPhone</key>
    <string>N/A</string>
    <key>OrganizationSupportPhone</key>
    <string>N/A</string>
    <key>OrganizationZipCode</key>
    <string>N/A</string>
    <key>SkipSetup</key>
    <array/>
    <key>SupervisorHostCertificates</key>
    <array/>
</dict>
</plist>
EOFINNER

echo "MDM removal complete. Rebooting system..."
reboot
EOF

# Display important warning in red text with asterisk borders
echo -e "\033[1;31m***********************************************************************\033[0m"
echo -e "\033[1;31m*                          CRITICAL WARNING                           *\033[0m"
echo -e "\033[1;31m***********************************************************************\033[0m"
echo -e "\033[1;31m* BEFORE tapping 'Next' during device setup:                          *\033[0m"
echo -e "\033[1;31m* 1. Press the Home button to exit to the Wi-Fi selection screen      *\033[0m"
echo -e "\033[1;31m* 2. Tap the (i) icon next to your connected Wi-Fi network            *\033[0m"
echo -e "\033[1;31m* 3. Select 'Forget This Network'                                     *\033[0m"
echo -e "\033[1;31m* 4. Go back to the Wi-Fi list but DO NOT connect to any network      *\033[0m"
echo -e "\033[1;31m* 5. Select 'Skip this step' at the bottom of the Wi-Fi screen        *\033[0m"
echo -e "\033[1;31m*                                                                     *\033[0m"
echo -e "\033[1;31m* FAILURE TO FOLLOW THESE STEPS WILL RESULT IN MDM REINSTALLATION!    *\033[0m"
echo -e "\033[1;31m***********************************************************************\033[0m"

echo -e "\033[1;32m***********************************************************************\033[0m"
echo -e "\033[1;32m*                       AFTER SETUP COMPLETES                         *\033[0m"
echo -e "\033[1;32m***********************************************************************\033[0m"
echo -e "\033[1;32m* Once you reach the home screen and setup is fully complete:         *\033[0m"
echo -e "\033[1;32m* 1. Open Settings > Wi-Fi                                            *\033[0m"
echo -e "\033[1;32m* 2. NOW you can safely connect to any Wi-Fi network                  *\033[0m"
echo -e "\033[1;32m* 3. Your device is free from MDM and ready to use!                   *\033[0m"
echo -e "\033[1;32m***********************************************************************\033[0m"

echo "Process completed."
echo "Note: The device is rebooting after MDM removal."
echo "      You will need to run checkra1n again to re-jailbreak if needed."

# Clean up iproxy process if still running
if [[ ! -z "$IPROXY_PID" ]] && ps -p $IPROXY_PID > /dev/null; then
    echo "Terminating iproxy process..."
    kill $IPROXY_PID
fi