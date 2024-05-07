import Elysia from "elysia";
import { PORT, type Matchmaker } from ".";
import { treaty } from "@elysiajs/eden";

export function serverPlugin(matchmaker: Matchmaker) {
  const plugin = new Elysia()
    .post("/servers", () => {

    })
    .put("/servers/:id", () => {

    })
    .delete("/servers/:id", () => {

    })
    .get("/servers", () => {

    })
    .get("/servers/:id", () => {

    })



  return { plugin, api: treaty<typeof plugin>(`localhost:${PORT}`) }
}
