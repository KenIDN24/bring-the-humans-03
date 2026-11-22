#!/bin/sh
# make-ad.sh — renders the bring-the-humans-03 TikTok ad end to end.
#
# This is the exact pipeline that produced the entry's video, kept in the
# repository as a record. It runs in three stages:
#   1. five silent scenes (ink ground, one press-pack ghost illustration
#      and Inter Bold on-screen text per beat) plus a plain magenta tail;
#   2. the voice track: five TTS lines placed at their scene starts over
#      a soft generated sine pad;
#   3. the press pack's official end-card recipe (llms.txt): the brand
#      badge overlaid from frame 1 until the card, the background washed
#      soft under the card, and the referral code typed into the card's
#      field once it rests.
#
# Inputs live OUTSIDE the repository (the repo holds no press copies):
#   ASSETS=/path/to/bth3-assets   press pack files + fonts + voice lines
#   WORK=/path/to/render-dir      scenes, filter scripts, intermediates
# Output: $WORK/ad.mp4 (1080x1920, ~25.7 s, H.264 + AAC).
set -eu

ASSETS=${ASSETS:?set ASSETS to the press-pack assets directory}
WORK=${WORK:?set WORK to a scratch render directory}
CODE=${CODE:-c8w480ny}
INTER="$ASSETS/fonts/Inter-Bold-static.ttf"
MONO="$ASSETS/fonts/JetBrainsMono-Bold-static.ttf"
cd "$WORK"

scene() { # scene <n> <seconds> <ghost-image-file-name>
  ffmpeg -v error -f lavfi -i color=c=0x191419:s=1080x1920:r=30:d=$2 \
    -loop 1 -t "$2" -i "$ASSETS/img/$3" \
    -filter_complex_script "scene$1.ff" -map '[v]' \
    -c:v libx264 -pix_fmt yuv420p -r 30 "scene$1.mp4"
}

# Stage 1 — scenes. The drawtext filter scripts (scene1..5.ff) centre a
# ghost at y=440 (420 px tall) and three lines of text from y=900, all
# inside the TikTok safe zone and clear of the badge box (x120 y272
# 330x128). Scene 5 is the call to action: no ghost, a magenta pill
# behind the word make.fun.
scene 1 3.7 ghost-pile-trophy.png
scene 2 5.5 ghost-laptop-recording.png
scene 3 5.5 ghost-judge-paddle.png
scene 4 5.0 ghost-flag-wrench.png
ffmpeg -v error -f lavfi -i color=c=0x191419:s=1080x1920:r=30:d=3.5 \
  -filter_complex_script scene5.ff -map '[v]' \
  -c:v libx264 -pix_fmt yuv420p -r 30 scene5.mp4
ffmpeg -v error -f lavfi -i color=c=0xc41c83:s=1080x1920:r=30:d=2.5 \
  -c:v libx264 -pix_fmt yuv420p -r 30 tail.mp4
printf "file 'scene1.mp4'\nfile 'scene2.mp4'\nfile 'scene3.mp4'\nfile 'scene4.mp4'\nfile 'scene5.mp4'\nfile 'tail.mp4'\n" > concat.txt
ffmpeg -v error -f concat -safe 0 -i concat.txt -c copy base-silent.mp4

# Stage 2 — voice + music pad (audio.ff): each TTS line is resampled and
# delayed to its scene start (0.2 / 3.9 / 9.4 / 14.9 / 19.9 s), the pad is
# four quiet sines (A3, C#4, E4, A4) faded in and out under the voice.
ffmpeg -v error -i base-silent.mp4 \
  -i "$ASSETS/voice/line1.mp3" -i "$ASSETS/voice/line2.mp3" \
  -i "$ASSETS/voice/line3.mp3" -i "$ASSETS/voice/line4.mp3" \
  -i "$ASSETS/voice/line5.mp3" \
  -f lavfi -i "aevalsrc=0.30*sin(2*PI*220*t)+0.22*sin(2*PI*277.18*t)+0.22*sin(2*PI*329.63*t)+0.12*sin(2*PI*440*t):s=44100:d=25.7" \
  -filter_complex_script audio.ff -map 0:v -map '[a]' \
  -c:v copy -c:a aac base.mp4

# Stage 3 — the press pack's end-card recipe, 9:16 numbers from the
# manifest: card length 2.5 s, the code rests at T+1.433, the field's
# caret sits at x=210 y=1232 (5x78), text midline 1271, size 62, ink
# 0x191419, JetBrains Mono Bold. T is the clip's duration minus the card.
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 base.mp4)
T=$(awk "BEGIN{print $D-2.5}")
REST=1.433
CODE_AT=$(awk "BEGIN{print $T+$REST}")
sed -e "s/__T__/$T/g" -e "s/__CODE_AT__/$CODE_AT/g" \
    -e "s/__MONO__|$MONO|g" -e "s/__CODE__/$CODE/g" \
    final.ff.tmpl > final.ff
ffmpeg -v error -i base.mp4 -c:v libvpx-vp9 \
  -i "$ASSETS/makefun-card-9x16-transparent.webm" \
  -i "$ASSETS/makefun-badge-9x16.png" \
  -filter_complex_script final.ff -map '[v]' -map '0:a?' \
  -c:v libx264 -pix_fmt yuv420p -crf 18 -c:a aac \
  -movflags +faststart ad.mp4

# Check the frames the bounty names: the first (badge in its place, no
# card) and the last (the card, the code in its field, no badge).
ffmpeg -v error -i ad.mp4 -frames:v 1 frame-first.png
ffmpeg -v error -sseof -0.1 -i ad.mp4 -frames:v 1 frame-last.png
echo "Rendered: $WORK/ad.mp4"
