#!/bin/bash
APP_PATH="/opt/ds-remote"
CONFIG_PATH="$1"

if [ -z "$CONFIG_PATH" ]; then
  echo "Usage: install.sh joystick.json"
  exit 1
fi

SERVICE_NAME="dualsense-override"

echo "Installing dependencies..."
sudo apt update -y
sudo apt install -y jq evtest curl

echo "Creating install directory..."

echo "Downloading main script..."
sudo curl -fsSL https://raw.githubusercontent.com/yaGatito/dualsense-override/master/ds-remote.sh -o "$APP_PATH/ds-remote.sh"

sudo chmod +x "$APP_PATH/ds-remote.sh"
# sudo chown $(whoami):$(whoami) "$APP_PATH/ds-remote.sh"

echo "Creating systemd service..."
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service" <<EOF
[Unit]
Description=DualSense Bash Remote
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash /opt/ds-remote/ds-remote.sh $CONFIG_PATH
Restart=on-failure
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
