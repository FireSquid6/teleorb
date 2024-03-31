import { getAuth } from "@/auth";
import { getDb } from "@/db";
import { startApp } from "@/index";
import { treaty } from "@elysiajs/eden";
import type { ApiContext } from "@/index";

export function getTreaty() {
  const db = getDb(":memory:");
  const ctx: ApiContext = {
    db: db,
    auth: getAuth(db),
    mode: "testing",
  };

  const app = startApp(ctx, 4126);
  const eden = treaty<typeof app>("localhost:4126");

  return {
    eden,
    db,
  };
}
