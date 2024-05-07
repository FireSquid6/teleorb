import { Matchmaker, PORT, type Client } from "."
import { Elysia, t } from "elysia"
import { treaty } from "@elysiajs/eden"


export function clientPlugin(matchmaker: Matchmaker) {
  const plugin = new Elysia()
    .ws("/client", {
      body: t.Object({
        message: t.String()
      }),
      message(ws, { message }) {
        const data = JSON.parse(message) as ClientMessage

        if (data.operation == "join") {
          if (data.joinRequest) {
            matchmaker.addClient({
              id: ws.id,
              gamemode: data.joinRequest.gamemode,
            })

            matchmaker.clientConnected.on(({ client, gameserver }) => {
              if (client.id !== ws.id) {
                return
              }

              ws.send(JSON.stringify(gameserver))
              ws.close()
            })

            ws.send("!success")
          } else {
            ws.send("!you screwed up.")
            ws.close()
          }
        }

        if (data.operation == "leave") {
          matchmaker.removeClient(ws.id)
          ws.close()
        }

        
      }
    })


  return { plugin: plugin, api: treaty<typeof plugin>(`localhost:${PORT}`) }

}


interface ClientMessage {
  operation: "join" | "leave"
  joinRequest: JoinRequest | undefined
}


interface JoinRequest {
  gamemode: string
}
