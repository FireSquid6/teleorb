import { describe, test, expect } from "bun:test";
import { startGatekeeper } from ".";



describe("Gatekeeper", () => {
  test("connects to the client", () => {
    startGatekeeper()
    
    const ws = new WebSocket("ws://localhost:3100/client")
    ws.send(JSON.stringify({
      operation: "join",
      joinRequest: {
        gamemode: "deathmatch"
      }
    }))

    ws.onmessage = (event) => {
      console.log(event.data)
    }

    expect(false).toBe(true)

  })

})


