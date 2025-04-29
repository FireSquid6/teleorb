import { describe, test, expect } from "bun:test";
import { startGatekeeper } from ".";



describe("Gatekeeper", () => {
  // needs work - not sure how to write tests for websocket connections
  // I'm sure i'll figure something out
  // probably with a custom function that returns a promise?
  //
  // test("connects to the client", () => {
  //   startGatekeeper()
  //   
  //   const ws = new WebSocket("ws://localhost:3100/client")
  //   ws.onopen = () => {
  //     ws.send(JSON.stringify({
  //       operation: "join",
  //       joinRequest: {
  //         gamemode: "deathmatch"
  //       }
  //     }))
  //   }
  //
  //   ws.onmessage = (event) => {
  //     console.log(event.data)
  //   }
  //
  //   expect(false).toBe(true)
  //
  // })

})


