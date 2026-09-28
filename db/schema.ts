import { pgTable, serial, integer, text, boolean, timestamp, uniqueIndex } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: serial().primaryKey(),
  email: text().notNull().unique(),
  passwordHash: text("password_hash").notNull(),
  displayName: text("display_name").notNull(),
  bio: text().notNull().default(""),
  avatarUrl: text("avatar_url"),
  isCreator: boolean("is_creator").notNull().default(false),
  createdAt: timestamp("created_at").defaultNow(),
});

// creatorId refers to the id of a creator in the app's content catalog
// (currently a curated catalog, not user-authored), so it is stored as
// plain text rather than a foreign key.
export const follows = pgTable(
  "follows",
  {
    id: serial().primaryKey(),
    userId: integer("user_id").notNull().references(() => users.id),
    creatorId: text("creator_id").notNull(),
    createdAt: timestamp("created_at").defaultNow(),
  },
  (t) => ({
    uniqUserCreator: uniqueIndex("follows_user_creator_idx").on(t.userId, t.creatorId),
  }),
);

export const subscriptions = pgTable(
  "subscriptions",
  {
    id: serial().primaryKey(),
    userId: integer("user_id").notNull().references(() => users.id),
    creatorId: text("creator_id").notNull(),
    tier: text().notNull().default("standard"),
    createdAt: timestamp("created_at").defaultNow(),
  },
  (t) => ({
    uniqUserCreator: uniqueIndex("subscriptions_user_creator_idx").on(t.userId, t.creatorId),
  }),
);
