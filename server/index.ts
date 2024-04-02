import { Elysia } from "elysia";

const app = new Elysia();

app.get("/", () => {
  return "Gameserver is up and running";
});

app.listen(3000, () => {
  console.log("HTTP server is running on port 3000");
});

const process = Bun.spawn(["bash", "./run-bin.sh"], {
  stdin: "ignore",
  stdout: "inherit",
  stderr: "inherit",
});
process.unref();
