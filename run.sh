#!/bin/bash
set -e


EXTENSION=${EXTENSION:-mp4}
LOGLEVEL=${LOGLEVEL:warning}
ENCODER=${ENCODER:-libx264}
PRESET=${PRESET:-veryfast}
CRF=${CRF:-35}
THREADS=${THREADS:-1}
CPU_LIMIT=${CPU_LIMIT:-30}
PRIORITY=${PRIORITY:-19}
ANALYZEDURATION=${ANALYZEDURATION:-100000000}
PROBESIZE=${PROBESIZE:-100000000}
WATCH=${WATCH:-/watch}
OUTPUT=${OUTPUT:-/output}
STORAGE=${STORAGE:-/storage}
EXTRAFLAGS=${EXTRAFLAGS}

run() {
  cd "$WATCH" || exit
  FILES=$(find . -type f -not -path '*/\.*'  | egrep '.*')
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

  echo $(date +"%Y-%m-%d-%T")

  trap 'exit' INT
  nice -"$PRIORITY" cpulimit -l "$CPU_LIMIT" -- ffmpeg \
    -hide_banner \
    -y \
    -loglevel "$LOGLEVEL" \
    -analyzeduration "$ANALYZEDURATION" \
    -probesize "$PROBESIZE" \
    -i "$input" \
    -c:v "$ENCODER" \
    -preset "$PRESET" \
    -crf "$CRF" \
    -threads "$THREADS" \
    $EXTRAFLAGS \
    "$destination"

  killall ffmpeg >/dev/null || true

  echo "Finished encoding $filepath"
  echo $(date +"%Y-%m-%d-%T")

  path=${filepath%/*}
  mv "$destination" "$OUTPUT"/"$path"
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
