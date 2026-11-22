// bring-the-humans-03 entry program (Node 22, standard library only).
//
// The entry itself is a video: an original short vertical ad for
// make.fun, posted publicly on TikTok. This repository only has to name
// it. The house reads VIDEO.json from the output directory, follows the
// address to the video and scores its views, so this program's whole
// job is to carry VIDEO.json from the repository root into /output,
// byte for byte, and to fail loudly when it cannot.
//
// In the grader the repository sits at /bot and results go to /output.
// Outside that container the two environment variables below stand in
// for the mounts, so the program can be run by hand the same way:
//
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, mkdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

const botDir = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const sourcePath = join(botDir, 'VIDEO.json');
const outputPath = join(outputDir, 'VIDEO.json');

// The gate reads the file exactly as it lands, so refuse to run at all
// when the source is missing or empty rather than writing a half entry.
let sourceSize = 0;
try {
  sourceSize = statSync(sourcePath).size;
} catch {
  console.error(`main.ts: no VIDEO.json at ${sourcePath}`);
  process.exit(1);
}
if (sourceSize === 0) {
  console.error(`main.ts: VIDEO.json at ${sourcePath} is empty`);
  process.exit(1);
}

mkdirSync(outputDir, { recursive: true });
copyFileSync(sourcePath, outputPath);

// The two runs of an entry must write the same bytes, and the gate
// compares the address it finds against the video itself, so check the
// copy landed whole before calling it done.
if (statSync(outputPath).size !== sourceSize) {
  console.error(`main.ts: copied VIDEO.json is ${statSync(outputPath).size} bytes, expected ${sourceSize}`);
  process.exit(1);
}
