#!/bin/bash

CONFIG="$1"

if [ -z "$CONFIG" ]; then
  sudo curl -fsSL https://raw.githubusercontent.com/yaGatito/dualsense-override/master/ps.sh -o "$APP_PATH/ps.sh"
  sudo chmod +x "$APP_PATH/ps.sh"
  sudo chown $(whoami):$(whoami) "$APP_PATH/ps.sh"
  sudo curl -fsSL https://raw.githubusercontent.com/yaGatito/dualsense-override/master/joystick.json -o "$APP_PATH/default.json"
  $CONFIG=$APP_PATH/default.json
fi

DEVICE=$(jq -r '.device' "$CONFIG")
LOG_FILE=$(jq -r '.log_file' "$CONFIG")

declare -A BINDINGS

while IFS="=" read -r key script; do
  BINDINGS["$key"]="$script"
done < <(jq -r '.bindings[] | "\(.key)=\(.script)"' "$CONFIG")

# key codes
declare -A KEYMAP
KEYMAP["BTN_SOUTH"]=304
KEYMAP["BTN_EAST"]=305
KEYMAP["BTN_NORTH"]=307
KEYMAP["BTN_WEST"]=308
KEYMAP["BTN_TL"]=310
KEYMAP["BTN_TR"]=311
KEYMAP["BTN_MODE"]=316

echo "Starting ds-remote bash daemon..." >> "$LOG_FILE"

evtest "$DEVICE" | while read -r line; do
  if [[ $line == *"type 1 (EV_KEY)"* && $line == *"value 1"* ]]; then
    for key in "${!BINDINGS[@]}"; do
      code=${KEYMAP[$key]}
      if [[ $line == *"code $code"* ]]; then
        script=${BINDINGS[$key]}
        echo "$(date) Trigger: $key -> $script" >> "$LOG_FILE"
        bash "$script" >> "$LOG_FILE" 2>&1 &
      fi
    done
  fi
done
