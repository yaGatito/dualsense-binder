# Install using curl and bash
It will download default `joystick.json` and `ps.sh` override for Dualsense Gamepad (PS button) to Launch PPSSPP Emulator located in `/home/gato/Downloads/PPSSPP-v1.19.3-anylinux-aarch64.AppImage`
<br>

```bash
curl -fsSL https://raw.githubusercontent.com/yaGatito/dualsense-override/master/install.sh | bash -s -- /home/gato/ds-remote/joystick.json
```

# Json-config example
```json
{
    "device": "/dev/input/by-id/usb-Sony_Interactive_Entertainment_DualSense_Wireless_Controller-if03-event-joystick",
    "log_file": "/home/gato/ds-remote.log",
    "bindings": [
        {
            "key": "BTN_MODE",
            "script": "/home/gato/ds-remote/ps.sh"
        }
    ]
}
```

# Script example
```bash
#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/gato/.Xauthority

APP="/home/gato/Downloads/PPSSPP-v1.19.3-anylinux-aarch64.AppImage"

if pgrep -f PPSSPP >/dev/null; then
    echo "PPSSPP already running"
    exit 0
fi

chmod +x "$APP"
"$APP" &
```

# Buttons to override
BTN_MODE   (PS)<br>
BTN_SOUTH  (X)<br>
BTN_EAST   (O)<br>
BTN_WEST   (□)<br>
BTN_NORTH  (△)<br>
BTN_TL     (L1)<br>
BTN_TR     (R1)<br>