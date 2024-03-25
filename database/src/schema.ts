import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const userTable = sqliteTable("user", {
  id: text("id").primaryKey().notNull(),
  email: text("email").notNull(),
  hashedPassword: text("hashedPassword").notNull(),
  username: text("username").notNull(),
  rating: integer("rating").notNull(),
});

export type InsertUser = typeof userTable.$inferInsert;
export type SelectUser = typeof userTable.$inferSelect;

// TOOD: the admins will be able to directly see the database
export const adminTable = sqliteTable("admin", {
  id: text("id").notNull().primaryKey(),
  email: text("email").notNull(),
  hashedPassword: text("hashedPassword").notNull(),
  emailVerified: text("emailVerified").notNull(),
});

export type InsertAdmin = typeof adminTable.$inferInsert;
export type SelectAdmin = typeof adminTable.$inferSelect;

export const matchesTable = sqliteTable("matches", {
  id: text("id").notNull().primaryKey(),
  userIds: text("userIds").notNull(),
});

export type InsertMatches = typeof matchesTable.$inferInsert;
export type SelectMatches = typeof matchesTable.$inferSelect;

export const serverTable = sqliteTable("server", {
  id: text("id").notNull().primaryKey(),
  token: text("token").notNull(),
});

export type InsertServer = typeof serverTable.$inferInsert;
export type SelectServer = typeof serverTable.$inferSelect;

export const sessionTable = sqliteTable("session", {
  id: text("id").notNull().primaryKey(),
  userId: text("userId")
    .notNull()
    .references(() => userTable.id),
  expiresAt: integer("expiresAt").notNull(),
});

export type InsertSession = typeof sessionTable.$inferInsert;
export type SelectSession = typeof sessionTable.$inferSelect;
