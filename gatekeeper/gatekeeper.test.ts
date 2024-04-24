import { treaty } from "@elysiajs/eden";
import type { App } from "./gatekeeper";
import { test, expect } from "bun:test";



test("Gatekeeper", async () => {
  const app = treaty<App>("localhost:6100")
  const myServer = {
    name: "My cool server",
    ip: "23.123.15.1",
    port: 3001,
  }

  app.gameservers.post({
    secret: "super secret text. This is probably not how you do security.",
    name: myServer.name,
    ip: myServer.ip,
    port: myServer.port,
  })
})


