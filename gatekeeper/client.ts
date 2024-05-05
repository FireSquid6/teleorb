import { Matchmaker, PORT } from "."
import Elysia from "elysia"
import { treaty } from "@elysiajs/eden"


export function clientPlugin(matchmaker: Matchmaker) {
  const plugin = new Elysia()


  return { plugin: plugin, api: treaty<typeof plugin>(`localhost:${PORT}`) }

}
