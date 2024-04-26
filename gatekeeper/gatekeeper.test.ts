import { treaty } from "@elysiajs/eden";
import type { App } from "./gatekeeper";
import { test, expect } from "bun:test";
import { app } from "./gatekeeper"



test("Gatekeeper", async () => {
  app.listen(6100)
  const api = treaty<App>("localhost:6100")
  
  const myServer = {
    name: "My cool server",
    ip: "23.123.15.1",
    port: 3001,
  }

  const postResult = await api.gameservers.post({
    secret: "super secret text. This is probably not how you do security.",
    name: myServer.name,
    ip: myServer.ip,
    port: myServer.port,
  })

  expect(postResult.status).toBe(200)
  expect(postResult).not.toBeUndefined()

  // @ts-expect-error we already ensured that postResult is not undefined. The compiler isn't smart enough to realize it
  const { id } = postResult
  const serverResponse = await api.gameservers.get()

  expect(serverResponse.data).toBe([{
    id,
    name: myServer.name,
    ip: myServer.ip,
    port: myServer.port,
  }])


  // send delete to server
})


