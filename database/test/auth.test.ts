import { test, expect } from "bun:test";
import { getTreaty } from "./helpers";
import { sessionTable, userTable } from "@/schema";
import { eq } from "drizzle-orm";

test("auth flow", async () => {
  const { eden, db } = getTreaty();

  // can create a user
  const userRes = await eden.user.post({
    email: "some@email.com",
    password: "a$ecurePassw3rd",
  });

  expect(userRes.status).toBe(201);

  // can sign out
  const deleteRes = await eden.session.delete({
    token: userRes.data?.session ?? "",
  });
  expect(deleteRes.status).toBeGreaterThanOrEqual(200);
  expect(deleteRes.status).toBeLessThan(300);

  const userSessions = await db
    .select()
    .from(sessionTable)
    .where(eq(sessionTable.userId, userRes.data?.session ?? ""));
  expect(userSessions).toHaveLength(0);

  const signInResult = await eden.session.post({
    email: "some@email.com",
    password: "a$ecurePassw3rd",
  });

  expect(signInResult.status).toBe(201);
});
