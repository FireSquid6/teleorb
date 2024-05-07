import Elysia from "elysia";
import { serverPlugin } from "./server";
import { clientPlugin } from "./client";

export const PORT = 3100

export function startGatekeeper() {
  const matchmaker = new Matchmaker()
  const app = new Elysia()

  const { plugin: server, api: serverApi } = serverPlugin(matchmaker)
  const { plugin: client, api: clientApi } = clientPlugin(matchmaker)
  
  app.use(server)
  app.use(client)

  app.listen(PORT)

  return { matchmaker, serverApi, clientApi }
}

export interface GameServer {
  id: string
  name: string
  ip: string
  port: number
  httpUrl?: string
}

export interface Client {
  id: string
  gamemode: string
}


export class Matchmaker {
  clientConnected: Signal<{client: Client, gameserver: GameServer}> = new Signal() 

  private clients: Client[] = []
  private servers: GameServer[] = []

  addServer(server: GameServer) {
    this.servers.push(server)
    this.process()
  }

  updateServer(id: string, server: GameServer) {
    const index = this.servers.findIndex((server) => server.id === id)
    if (index === -1) {
      return
    }

    this.servers[index] = server
    this.process()
  }

  removeServer(id: string) {
    this.servers = this.servers.filter((server) => server.id !== id)
    this.process()
  }

  addClient(client: Client) {
    this.clients.push(client)
    this.process()
  }

  updateClient(id: string, client: Client) {
    const index = this.clients.findIndex((client) => client.id === id)
    if (index === -1) {
      return
    }

    this.clients[index] = client
    this.process()
  }

  removeClient(id: string) {
    this.clients = this.clients.filter((client) => client.id !== id)
    this.process()
  }

  private process() {
    // TODO: figure out how to match clients with servers

  }

  private match(client: Client, server: GameServer) {
    this.clients = this.clients.filter((client) => client.id !== client.id)
    this.clientConnected.emit({client, gameserver: server})
  }
}



export class Signal<T> {
  private listeners: ((arg: T) => void)[] = []

  on(f: (arg: T) => void) {
    this.listeners.push(f)
  }

  off(f: (arg: T) => void) {
    this.listeners = this.listeners.filter((listener) => listener !== f)
  }

  emit(arg: T) {
    for (const listener of this.listeners) {
      listener(arg)
    }
  }

  dispose() {
    this.listeners = []
  }

  get listenerCount() {
    return this.listeners.length
  }
}



startGatekeeper()
