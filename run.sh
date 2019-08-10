#!/bin/bash
set -e 0

EXTENSION=${EXTENSION:-mp4}
ENCODER=${ENCODER:-libx265}
PRESET=${PRESET:-veryfast}
CRF=${CRF:-28}
THREADS=${THREADS:-2}
CPU_LIMIT=${CPU_LIMIT:-30}
PRIORITY=${PRIORITY:-19}
WATCH=${WATCH:-/watch}
OUTPUT=${OUTPUT:-/output}
STORAGE=${STORAGE:-/storage}

run() {
  cd "$WATCH" || exit
  FILES=$(find . -type f -not -path '*/\.*')
  cd ..
  echo "$FILES" | while read -r FILE
  do
    process "$FILE"
  done;
}

process() {
  file=$1
  filepath=${file:2}
  input="$WATCH"/"$filepath"
  destination="$STORAGE"/"${filepath%.*}"."$EXTENSION"
  cd "$STORAGE" && mkdir -p "$(dirname "$filepath")" && cd ..

  echo "Encoding $filepath"

  nice -"$PRIORITY" cpulimit -l "$CPU_LIMIT" -- ffmpeg \
    -hide_banner \
    -y \
    -loglevel warning \
    -i "$input" \
    -c:v "$ENCODER" \
    -preset "$PRESET" \
    -crf "$CRF" \
    -threads "$THREADS" \
    -stats \
    "$destination"

  echo "Encoded $filepath"

  path=${filepath%/*}
  mv "$STORAGE"/"$path" "$OUTPUT"/"$path"
  rm -rf "$WATCH"/"$path"
}

processes=$(ps aux | grep -i "ffmpeg" | awk '{print $11}')
for i in $processes; do
  if [ "$i" == "ffmpeg" ] ;then
    echo 'Waiting for current econding to complete...'
    exit 0
  fi
done

run
