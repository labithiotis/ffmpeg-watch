# ffmpeg-watch

A Docker container designed to watch a directory and encode any file automatically.

You need to set your watch and output folders either as ENVIRONMENT variables or docker-compose:
```docker-compose 
services:
  ffmpeg-watch:
    container_name: ffmpeg-watch
    image: labithiotis/ffmpeg-watch
    restart: always
    environment:
      ENCODER: libx265
      CRF: 20
      PRESET: slow
      TUNE: film
      EXTENSION: mp4
    volumes:
      - 'PATH_TO_STORAGE:/storage'
      - 'PATH_TO_WATCH:/watch'
      - 'PATH_TO_OUTPUT:/output'
```

## Options

|Variables|Default||
|:---|:---|:---|
| WATCH       | /watch | Location of files to encode.         |
| OUTPUT       | /output | Where encoded files are saved.              |
| STORAGE       | /storage |Temp directory while processing files.|
| EXTENSION     | mp4     |  |
| ENCODER     | libx265     | https://trac.ffmpeg.org/wiki/Encode/H.265 |
| CRF           | 20      | A quality factor for the encode from 0.0-58.0. Lower numbers are better quality and higher file size.              |
| PRESET        | slow  | Set as low as you're willing to wait. See https://x265.readthedocs.io/en/default/presets.html |
| TUNE        | film  |  Avaiable options for h.265 `psnr`, `ssim`, `grain`, `zerolatency`, `fastdecode`. See https://trac.ffmpeg.org/wiki/Encode/H.264#crf |
