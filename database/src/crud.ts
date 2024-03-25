import { eq } from "drizzle-orm";
import { sessionTable, userTable, type InsertUser } from "./schema";
import type { ApiContext } from ".";

export async function insertUser({ db }: ApiContext, user: InsertUser) {
  await db.insert(userTable).values(user);
}

export async function getUserByEmail({ db }: ApiContext, email: string) {
  const users = await db
    .select()
    .from(userTable)
    .where(eq(userTable.email, email));
  return users[0];
}

export async function getUserById({ db }: ApiContext, id: string) {
  const users = await db.select().from(userTable).where(eq(userTable.id, id));
  return users[0];
}

export async function createSession({ auth }: ApiContext, userId: string) {
  const session = await auth.createSession(userId, {});
  return session;
}

export async function deleteSession({ auth }: ApiContext, id: string) {
  await auth.invalidateSession(id);
}

export async function getUserFromSessionId(
  { db }: ApiContext,
  sessionId: string,
) {
  const users = await db
    .select()
    .from(sessionTable)
    .where(eq(sessionTable.id, sessionId));

  if (users.length === 0) {
    return null;
  }

  return users[0];
}

export async function killUserSessions({ db }: ApiContext, userId: string) {
  await db.delete(sessionTable).where(eq(sessionTable.userId, userId));
}
