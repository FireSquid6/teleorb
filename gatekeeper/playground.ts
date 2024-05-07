import { startGatekeeper } from "."

startGatekeeper()

const ws = new WebSocket("ws://localhost:3100/client")
ws.onopen = () => {
  ws.send(JSON.stringify({
    operation: "join",
    joinRequest: {
      gamemode: "deathmatch"
    }
  }))
}


ws.onmessage = (event) => {
  console.log(event.data)
}
