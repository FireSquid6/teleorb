import { DrizzleSQLiteAdapter } from "@lucia-auth/adapter-drizzle";
import { Lucia, generateId } from "lucia";
import { sessionTable, userTable } from "./schema";
import { isValidEmail, isValidPassword } from "./validators";
import { Argon2id } from "oslo/password";
import { insertUser } from "./crud";
import type { BunSQLiteDatabase } from "drizzle-orm/bun-sqlite";
import type { ApiContext } from ".";

export function getAuth(db: BunSQLiteDatabase): Lucia {
  const adapter = new DrizzleSQLiteAdapter(db, sessionTable, userTable);
  const auth = new Lucia(adapter, {
    sessionCookie: {
      attributes: {
        secure: true, // set `Secure` flag in HTTPS
      },
    },
    getUserAttributes(attributes) {
      return {
        email: attributes.email,
      };
    },
  });

  return auth;
}

declare module "lucia" {
  interface Register {
    Lucia: typeof Lucia;
    DatabaseUserAttributes: {
      email: string;
    };
  }
}

export interface UserProfile {
  username: string;
  rating: number;
}

export async function createUser(
  apiContext: ApiContext,
  email: string,
  password: string,
  profile?: UserProfile | undefined,
): Promise<[string, string]> {
  if (profile === undefined) {
    profile = {
      username: "somerandomusername",
      rating: 0,
    };
  }

  if (!isValidEmail(email)) {
    return ["", "invalid email"];
  }
  if (!isValidPassword(password)) {
    return ["", "invalid password"];
  }

  const hashedPassword = await new Argon2id().hash(password);
  const userId = generateId(15);

  insertUser(apiContext, {
    id: userId,
    email,
    hashedPassword,
    username: profile.username,
    rating: profile.rating,
  });

  try {
  } catch (e) {
    return ["", "user already exists"];
  }

  return [userId, ""];
}
