## Example usage .sh
```shell
    curl -fsSL https://github.com/yaGatito/dualsense-override/releases/download/v0.0.2/install.sh | bash -s -- /home/gato/joystick.json
```



## Build and run Go
`go run override.go joystick.json`

## Launch 
`./ds-remote config.json --daemon`

## Json-config example
```json
{
    "device": "/dev/input/by-id/usb-Sony_Interactive_Entertainment_DualSense_Wireless_Controller-if03-event-joystick",
    "log_file": "/var/log/ds-remote.log",
    "bindings": [
        {
            "key": "BTN_MODE",
            "script": "/home/gato/scripts/ps.sh"
        },
        {
            "key": "BTN_SOUTH",
            "script": "/home/gato/scripts/x.sh"
        }
    ]
}
```

## Script example
```bash
#!/bin/bash
echo "PS pressed at $(date)" >> /tmp/ps.log
```

## Buttons to override
BTN_MODE   (PS)<br>
BTN_SOUTH  (X)<br>
BTN_EAST   (O)<br>
BTN_WEST   (□)<br>
BTN_NORTH  (△)<br>
BTN_TL     (L1)<br>
BTN_TR     (R1)<br>