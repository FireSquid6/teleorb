import Elysia from "elysia";
import { PORT, type Matchmaker } from ".";
import { treaty } from "@elysiajs/eden";

export function serverPlugin(matchmaker: Matchmaker) {
  const plugin = new Elysia()
    



  return {plugin, treaty: treaty<typeof plugin>(`localhost:${PORT}`) }
}
