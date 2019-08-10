#!/bin/bash
set -e 0

ENCODER=${ENCODER:-libx265}
CRF=${CRF:-20}
PRESET=${PRESET:-slow}
TUNE=${TUNE:-film}
EXTENSION=${EXTENSION:-mp4}
WATCH=${WATCH:-./watch}
OUTPUT=${OUTPUT:-./output}
TMP=${TMP:-./tmp}

run() {
  cd "$WATCH" || exit
  FILES=$(ls -R | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }')
  cd ..
  for FILE in $FILES; do
    process "$FILE"
  done;
}

process() {
  file=$1
  filepath=${file:2}
  in="$WATCH"/"$filepath"
  tmp="$TMP"/"${filepath%.*}"."$EXTENSION"
  cd "$TMP" && mkdir -p "$(dirname "$filepath")" && cd ..

  echo "Encoding $filepath"

  ffmpeg \
    -hide_banner \
    -y \
    -loglevel panic \
    -i "$in" \
    "$tmp" \
    -map 0 \
    -c copy \
    -c:v "$ENCODER" \
    -preset "$PRESET" \
    -crf "$CRF" \
    -tune "$TUNE"

  echo "Encoded $filepath"

  path=${filepath%/*}
  mv "$TMP"/"$path" "$OUTPUT"/"$path"
  rm -rf "$WATCH"/"$path"
}

processes=$(ps aux | grep -i "ffmpeg" | awk '{print $11}')
for i in $processes; do
  if [ "$i" == "ffmpeg" ] ;then
    exit 0
  fi
done

run
