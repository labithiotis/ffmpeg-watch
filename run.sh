#!/bin/bash
set -e 0

ENCODER=${ENCODER:-libx265}
CRF=${CRF:-20}
PRESET=${PRESET:-slow}
TUNE=${TUNE:-film}
EXTENSION=${EXTENSION:-mp4}
THREADS=${THREADS:-1}
WATCH=${WATCH:-/watch}
OUTPUT=${OUTPUT:-/output}
STORAGE=${STORAGE:-/storage}

run() {
  cd "$WATCH" || exit
  FILES=$(find . -type f -not -path '*/\.*')
  cd ..
  for FILE in $FILES; do
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

  time ffmpeg \
    -hide_banner \
    -y \
    -loglevel warning \
    -stats \
    -i "$input" \
    "$destination" \
    -map 0 \
    -c copy \
    -c:v "$ENCODER" \
    -preset "$PRESET" \
    -crf "$CRF" \
    -tune "$TUNE"
    -threads THREADS

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
