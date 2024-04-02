import { Elysia } from "elysia";

const app = new Elysia();

app.get("/", () => {
  return "Gameserver is up and running";
});

app.listen(3000, () => {
  console.log("HTTP server is running on port 3000");
});
