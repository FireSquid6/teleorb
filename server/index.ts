import { Elysia } from "elysia";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const config = {
  enabled: true,
};

const configPath = path.join(
  os.homedir(),
  ".config",
  "teleorb-dedicated-server.json",
);

const json = JSON.stringify(config, null, 2);
fs.writeFileSync(configPath, json, { flag: "w" });

const app = new Elysia();
const process = Bun.spawn(["bash", "./run-bin.sh"], {
  stdin: "ignore",
  stdout: "inherit",
  stderr: "inherit",
});
process.unref();

app.get("/", () => {
  const usage = process.resourceUsage();
  if (!usage) {
    return {
      message: "Something went wrong.",
    };
  }
  return {
    message: "Everything is ok.",
    ops: usage.ops,
    switches: usage.contextSwitches,
    cpuTime: usage.cpuTime,
    memory: usage.shmSize,
  };
});

app.listen(3000, () => {
  console.log("HTTP server is running on port 3000");
});
