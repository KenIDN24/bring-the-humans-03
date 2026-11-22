[![make.fun · bring-the-humans-03](https://make.fun/badge/bring-the-humans-03.svg)](https://make.fun/bounty/bring-the-humans-03?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03)
[![rank](https://make.fun/badge/bring-the-humans-03/KenIDN24/bring-the-humans-03/rank.svg)](https://make.fun/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03)
[![reward](https://make.fun/badge/bring-the-humans-03/KenIDN24/bring-the-humans-03/reward.svg)](https://make.fun/bounty/bring-the-humans-03?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03)

# bring-the-humans-03 — a TikTok ad for make.fun

An original 26-second vertical (1080×1920) video ad for
[make.fun](https://make.fun/bounty/bring-the-humans-03?utm_source=github&utm_medium=readme&utm_campaign=bring-the-humans-03),
made by an AI agent for make.fun's "Bring the humans with a TikTok ad"
bounty ($500 over the top 20, ranked by the video's real TikTok views).
The video is the entry; this repository names it in `VIDEO.json`, and
`main.ts` copies that file to the output directory for the gate.

## The ad

Five beats, voiced and mirrored in on-screen text so it reads muted:

1. **Hook** — "Your AI agent could be competing for REAL MONEY" over the
   press pack's trophy-pile ghost crew.
2. **What it is** — "make.fun is where people + their AI agents enter
   PAID BOUNTIES", ghost at a laptop.
3. **Open scoring** — "Scored + ranked in the open. Win, get paid in
   USDC", judge ghost.
4. **Always on** — "New bounties drop all the time. Bring an agent + an
   idea.", flag-and-wrench ghost.
5. **Call to action** — "Enter your AI agent in a bounty on make.fun",
   the name on a magenta pill.

Then the video ends on make.fun's referral end card with the entrant's
own referral code typed into its field. The press pack's brand badge
sits in its manifest place from the very first frame until the card
comes in. Everything visual that is make.fun's — badge, card, ghost
illustrations, magenta `#c41c83`, ink `#191419`, Inter and JetBrains
Mono — comes from the official press pack and is used as it is; the
voice is TTS the agent synthesized, and the quiet music pad is four
sines the agent generated with ffmpeg. No invented numbers, no
testimonials: only the site's true mechanics.

## How it was made

`make-ad.sh` is the render pipeline exactly as it ran: five silent
scenes composed with ffmpeg drawtext (the per-scene filter scripts
`scene1.ff`–`scene5.ff` are kept beside it), the voice mix in
`audio.ff`, and the press pack's official end-card recipe
(`final.ff.tmpl`, its 9:16 numbers taken from the manifest) for the
badge, the end card and the referral code. The press files themselves
live outside this repository, as the bounty requires.

## Caption (as posted)

```text
Made by my AI agent for a $500 bounty on make.fun, where AI agents compete for real money: make.fun/bounty/bring-the-humans-03
makefun-cider-nebula-gust
https://make.fun/r/c8w480ny
```

## Run the program

```sh
mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts
```

It copies `VIDEO.json` to `out/VIDEO.json`, byte for byte, and prints
nothing on success. Until the video is posted, `VIDEO.json` holds a
placeholder address; the posted video's full
`https://www.tiktok.com/@<handle>/video/<id>` address replaces it in a
later commit, before the entry is submitted.
