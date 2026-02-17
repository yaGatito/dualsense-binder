#!/bin/bash
set -e

CONFIG_PATH="$1"

if [ -z "$CONFIG_PATH" ]; then
  echo "Usage: install.sh /path/to/config.json"
  exit 1
fi

INSTALL_DIR="/opt/ds-remote"
SERVICE_NAME="ds-remote"

echo "Installing dependencies..."
sudo apt update -y
sudo apt install -y jq evtest curl

echo "Creating install directory..."
sudo mkdir -p "$INSTALL_DIR"

echo "Downloading main script..."
sudo curl -fsSL https://github.com/yaGatito/dualsense-override/releases/download/v0.0.2/ds-remote.sh \
  -o "$INSTALL_DIR/ds-remote.sh"

sudo chmod +x "$INSTALL_DIR/ds-remote.sh"

echo "Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service" <<EOF
[Unit]
Description=DualSense Bash Remote
After=multi-user.target

[Service]
ExecStart=$INSTALL_DIR/ds-remote.sh $CONFIG_PATH
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME

echo "Installation complete!"
echo "Check logs with: journalctl -u $SERVICE_NAME -f"
