import { Elysia, t } from "elysia";
import { cors } from "@elysiajs/cors";
import { createUser } from "./auth";
import { createSession, getUserFromSessionId, killUserSessions } from "./crud";
import { Argon2id } from "oslo/password";
import { getUserByEmail } from "./crud";
import type { Lucia } from "lucia";
import type { BunSQLiteDatabase } from "drizzle-orm/bun-sqlite";

export interface ApiContext {
  db: BunSQLiteDatabase;
  auth: Lucia;
  mode: "testing" | "production"; //testing mode is the same as development mode
}

// TODO: combine user and profile into one table

export function startApp(apiContext: ApiContext, port: number = 3000) {
  const app = new Elysia()
    .use(cors())
    .post(
      "/user",
      async (ctx) => {
        const { email, password } = ctx.body;

        const [id, error] = await createUser(apiContext, email, password);

        if (error) {
          ctx.set.status = 400;
          return {
            user: "",
            session: "",
            error,
          };
        }

        const session = await createSession(apiContext, id);

        ctx.set.status = 201;
        return {
          user: id,
          session: session.id,
          error: "",
        };
      },
      {
        body: t.Object({
          email: t.String(),
          password: t.String(),
        }),
      },
    )
    .post(
      "/session",
      async (ctx) => {
        const { email, password } = ctx.body;

        const user = await getUserByEmail(apiContext, email);

        // is done to protect against timing attacks
        const userPassword = user.hashedPassword ?? "blahblahblah";

        const validPassword = await new Argon2id().verify(
          userPassword,
          password,
        );

        if (!validPassword) {
          ctx.set.status = 400;
          return "invalid email or password";
        }

        const sesion = await createSession(apiContext, user.id);
        ctx.set.status = 201;

        return {
          session: sesion.id,
        };
      },
      {
        body: t.Object({
          email: t.String(),
          password: t.String(),
        }),
      },
    )

    .delete(
      "/session",
      async (ctx) => {
        const user = await getUserFromSessionId(apiContext, ctx.body.token);

        if (!user) {
          ctx.set.status = 400;
          return "invalid token";
        }

        await killUserSessions(apiContext, user.id);

        ctx.set.status = 200;
      },
      {
        body: t.Object({
          token: t.String(),
        }),
      },
    )
    .listen(port, () => {
      console.log(`🔭 Warden is online and running on port ${port}`);
    });

  return app;
}
