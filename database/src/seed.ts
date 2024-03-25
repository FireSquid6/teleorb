import type { ApiContext } from ".";
import { userTable } from "./schema";
import { Argon2id } from "oslo/password";

export async function seed({ db }: ApiContext) {
  await db.insert(userTable).values([
    {
      id: "ABCDEFGHIJKLMNO",
      email: "jondoe@example.com",
      hashedPassword: await new Argon2id().hash("Password#1"),
      username: "JonDoe",
      rating: 0,
    },
  ]);
}
