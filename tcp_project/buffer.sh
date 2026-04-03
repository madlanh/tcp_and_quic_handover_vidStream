#!/bin/bash

LOGFILE=$1
OUTFILE=$2

if [ -z "$LOGFILE" ] || [ -z "$OUTFILE" ]; then
  echo "Usage: ./buffer.sh mpv.log hasil.log"
  exit 1
fi

echo "Menghitung buffering dari $LOGFILE ..."
echo "Hasil akan disimpan ke $OUTFILE"

BUFFER_START=0
BUFFER_EVENTS=0
TOTAL_BUFFER=0

while read -r line; do

  if echo "$line" | grep -q "stalling at"; then
    T=$(echo "$line" | grep -o "stalling at.*" | grep -o "[0-9]\+\.[0-9]\+")
    BUFFER_START=$T
    BUFFER_EVENTS=$((BUFFER_EVENTS+1))
  fi

  if echo "$line" | grep -q "resuming playback"; then
    T=$(echo "$line" | grep -o "[0-9]\+\.[0-9]\+")
    if [ "$BUFFER_START" != 0 ]; then
      DUR=$(echo "$T - $BUFFER_START" | bc)
      TOTAL_BUFFER=$(echo "$TOTAL_BUFFER + $DUR" | bc)
      BUFFER_START=0
    fi
  fi

done < "$LOGFILE"

echo "========== HASIL ==========" | tee "$OUTFILE"
echo "Jumlah buffering events : $BUFFER_EVENTS" | tee -a "$OUTFILE"
echo "Total buffering time    : $TOTAL_BUFFER detik" | tee -a "$OUTFILE"
echo "===========================" | tee -a "$OUTFILE"

echo "File hasil dibuat: $OUTFILE"
