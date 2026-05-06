# Videos

Drop stock video files here. Anything in this folder is bundled with the app at build time.

## How HiveTabView picks a video

The Hive tab tries to play (in this order):
1. `hive-entrance.mp4` (or .mov, .m4v)
2. `hive-internal.mp4`
3. `hive-topdown.mp4`
4. Any other `.mp4` / `.mov` / `.m4v` file in this folder

If none are found, it falls back to the dark placeholder card.

## Recommended specs

- **Format:** H.264 in `.mp4` (smallest file size, best compatibility)
- **Resolution:** 1080p or smaller (1920x1080 is plenty for a 220pt video frame)
- **Duration:** 30s – 2 min loops well; longer is fine but bloats the app bundle
- **Audio:** muted in player by default — strip the audio track to save space
- **Bitrate:** 2–4 Mbps gives clean image at small file size

## Where to find stock bee footage

Free, no-attribution-needed:
- [Pexels](https://www.pexels.com/search/videos/bees/) — search "bees", "beehive", "honeybee"
- [Pixabay](https://pixabay.com/videos/search/bees/)
- [Coverr](https://coverr.co/) — limited bee selection but high quality

Free, attribution required:
- [Mixkit](https://mixkit.co/free-stock-video/bees/)

Paid (higher quality):
- [Storyblocks](https://www.storyblocks.com)
- [Artgrid](https://artgrid.io)

## Adding a new video

1. Save the file here as `hive-entrance.mp4` (or another supported name).
2. Build and run — Xcode auto-picks up new files in this folder reference.
3. No `project.pbxproj` edits needed.

## Stripping audio (optional, smaller bundle)

```bash
ffmpeg -i source.mp4 -c:v copy -an hive-entrance.mp4
```
