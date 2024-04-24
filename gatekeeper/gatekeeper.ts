import { Elysia, t } from "elysia";


interface GameServer {
  id: string
  name: string
  ip: string
  port: number
  httpUrl?: string
}


function generateRandom(): string {
  return Math.random().toString(36).substring(2, 15)
}

const secret = "super secret text. This is probably not how you do security."

export const app = new Elysia()
  .state("gameservers", [] as GameServer[])
  .state("keys", new Map<string, string>())
  .get("/gameserver/:id", ({ set, params: { id }, store }): GameServer | void => {
    for (const gameserver of store.gameservers) {
      if (gameserver.id === id) {
        set.status = 200
        return gameserver
      }
    }

    set.status = 404
  }, {
    params: t.Object({
      id: t.String()
    })
  })
  .get("/gameservers", ({ store }): GameServer[] => {
    return store.gameservers
  })
  .post("/gameservers", async ({ store, set, body }): Promise<{ key: string } | void> => {

    if (secret !== body.secret) {
      await new Promise((resolve) => setTimeout(resolve, 2000))
      set.status = 401
      return
    }

    const key = generateRandom()
    const id = generateRandom()

    store.gameservers.push({
      id,
      name: body.name,
      ip: body.ip,
      port: body.port,
      httpUrl: body.httpUrl,
    })

    store.keys.set(key, key)


    return {
      key
    }
  }, {
    body: t.Object({
      name: t.String(),
      ip: t.String(),
      secret: t.String(),
      httpUrl: t.Optional(t.String()),
      port: t.Number(),
    })
  })

export type App = typeof app

function startApp() {
  app.listen(6100, () => {
    console.log("Listening on 6100")
  })
}

startApp()
