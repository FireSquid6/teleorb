import { readdir, mkdir } from "node:fs/promises";
import { join, relative, dirname } from "node:path";
import { spawnSync } from "node:child_process";

process.chdir(import.meta.dirname);
process.chdir("..");

const ART_DIR = "art";
const OUT_DIR = join("public", "art");

async function* walk(dir: string): AsyncGenerator<string> {
  const entries = await readdir(dir, { withFileTypes: true });
  for (const entry of entries) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      yield* walk(path);
    } else if (entry.isFile()) {
      yield path;
    }
  }
}

for await (const file of walk(ART_DIR)) {
  if (!file.endsWith(".ase") && !file.endsWith(".aseprite")) continue;

  const rel = relative(ART_DIR, file);
  const outPath = join(OUT_DIR, rel).replace(/\.(ase|aseprite)$/, ".png");

  await mkdir(dirname(outPath), { recursive: true });

  const result = spawnSync(
    "libresprite",
    ["-b", file, "--sheet", outPath],
    { stdio: "inherit" },
  );

  if (result.status !== 0) {
    console.error(`Failed to export ${file}`);
    process.exit(result.status ?? 1);
  }

  console.log(`${file} -> ${outPath}`);
}
