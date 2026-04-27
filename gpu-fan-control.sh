#!/bin/bash

# GPU Fan Control Script
# Reads GPU temp from Ollama VM via SSH, controls R720 fans via local IPMI

OLLAMA_HOST="192.168.XX.YYY"
OLLAMA_USER="YOU_USER_NAME"
SSH_KEY="/root/.ssh/gpu_fan_key"
LOG="/var/log/gpu-fan.log"

while true; do
  TEMP=$(ssh -i $SSH_KEY ${OLLAMA_USER}@${OLLAMA_HOST} \
    "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader" 2>/dev/null)

  # Validate we got a number
  if ! [[ "$TEMP" =~ ^[0-9]+$ ]]; then
    echo "$(date) ERROR: Could not read GPU temp" >> $LOG
    sleep 30
    continue
  fi

  if [ "$TEMP" -gt 85 ]; then
    SPEED=0x64
    LABEL="100%"
  elif [ "$TEMP" -gt 75 ]; then
    SPEED=0x50
    LABEL="80%"
  elif [ "$TEMP" -gt 65 ]; then
    SPEED=0x3c
    LABEL="60%"
  elif [ "$TEMP" -gt 50 ]; then
    SPEED=0x1e
    LABEL="30%"
  else
    SPEED=0x14
    LABEL="20%"
  fi

  # Enable manual fan control
  ipmitool raw 0x30 0x30 0x01 0x00

  # Set safe baseline for all fans
  ipmitool raw 0x30 0x30 0x02 0xff 0x14

  # Set fan 2 speed to respond to GPU temp
  ipmitool raw 0x30 0x30 0x02 0x01 $SPEED

  echo "$(date) GPU: ${TEMP}C Fans: ${LABEL}" >> $LOG

  sleep 10
done
