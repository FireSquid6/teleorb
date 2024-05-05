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


const secret = "a secret. This will be changed when warden is implemented."

export const app = new Elysia()
  .state("gameservers", [] as GameServer[])
  .state("keys", new Map<string, string>())
  .state("clients", [] as string[])
  .get("/servers/:id", ({ set, params: { id }, store }): GameServer | undefined  => {
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
  .get("/servers", ({ store }): GameServer[] => {
    return store.gameservers
  })
  .delete("/servers/:id", async ({ store, set, body, params: {id} } ) => {
    if (id !== store.keys.get(body.key)) {
      set.status = 401
      await new Promise((resolve) => setTimeout(resolve, 5000))
    }


  }, {
    body: t.Object({
      key: t.String(),
    }),
    params: t.Object({
      id: t.String()
    })
  })
  .post("/servers", async ({ store, set, body }): Promise<{ key: string, id: string } | undefined> => {
    if (secret !== body.secret) {
      await new Promise((resolve) => setTimeout(resolve, 5000))
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
      key, id
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
  .put("/servers/:id", async ({ store, set, body, params: {id} }) => {
    
  })
  .post("/clients", async ({ store, set, body }) => {

  })
  .delete("/clients/:id", async ({ store, set, body, params: {id} }) => {

  })

export type App = typeof app
