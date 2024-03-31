import { drizzle, type BunSQLiteDatabase } from "drizzle-orm/bun-sqlite";
import { migrate } from "drizzle-orm/bun-sqlite/migrator";
import { Database } from "bun:sqlite";

export function getDb(filename: string = "warden.db"): BunSQLiteDatabase {
  const sqlite = new Database(filename);
  const db = drizzle(sqlite);
  migrate(db, { migrationsFolder: `./migrations` });
  return db;
}
