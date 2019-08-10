# ffmpeg-watch

A Docker container designed to watch a directory and encode any file.

###/watch
###/output

## Options

| Variables | Default |                                                                                                         |
|---------------|---------|--------------------------------------------------------------------------------------------------------------------|
| EXTENSION     | mp4     |  |
| ENCODER       | libx265 | Pick the encoder to use. The below options may behave differently when not using the libx265 encoder.              |
| CRF           | 20      | A quality factor for the encode from 0.0-58.0. Lower numbers are better quality and higher file size.              |
| PRESET        | slow  | x265 encoder preset. Set as low as you're willing to wait. See https://x265.readthedocs.io/en/default/presets.html |
