#!/bin/bash

# Quick Fix Wrapper for PanelX Installation
# This downloads the latest script and forces a fresh copy

echo "🔄 Downloading latest PanelX installation script..."

# Remove old script
rm -f install-panelx.sh

# Download with cache bypass
wget --no-cache --no-cookies -O install-panelx.sh "https://raw.githubusercontent.com/mipisoft/PanelX-V3.0.0-PRO/main/install-panelx.sh?$(date +%s)"

# Make executable
chmod +x install-panelx.sh

# Show first 40 lines to verify it's the right version
echo ""
echo "✅ Script downloaded. Verifying version..."
if grep -q "Running as root user" install-panelx.sh; then
    echo "✅ Correct version detected (allows root execution)"
    echo ""
    echo "🚀 Starting installation..."
    echo ""
    ./install-panelx.sh
else
    echo "❌ Old version detected. Trying alternative download..."
    # Try alternative method
    curl -H 'Cache-Control: no-cache' -o install-panelx.sh "https://raw.githubusercontent.com/mipisoft/PanelX-V3.0.0-PRO/main/install-panelx.sh"
    chmod +x install-panelx.sh
    if grep -q "Running as root user" install-panelx.sh; then
        echo "✅ Correct version downloaded via curl"
        ./install-panelx.sh
    else
        echo "❌ Still getting cached version. Manual fix needed."
        echo ""
        echo "Please try this instead:"
        echo "  wget https://github.com/mipisoft/PanelX-V3.0.0-PRO/raw/main/install-panelx.sh"
        echo "  chmod +x install-panelx.sh"
        echo "  ./install-panelx.sh"
    fi
fi
