import type { Config } from "@netlify/functions";
import { eq } from "drizzle-orm";
import { db } from "../../db/index.js";
import { users } from "../../db/schema.js";
import { AuthRequiredError, requireUserId } from "../lib/auth.js";

function publicUser(user: typeof users.$inferSelect) {
  return {
    id: user.id,
    email: user.email,
    displayName: user.displayName,
    bio: user.bio,
    avatarUrl: user.avatarUrl,
    isCreator: user.isCreator,
  };
}

export default async (req: Request) => {
  let userId: number;
  try {
    userId = await requireUserId(req);
  } catch (e) {
    if (e instanceof AuthRequiredError) return Response.json({ error: e.message }, { status: 401 });
    throw e;
  }

  if (req.method === "GET") {
    const [user] = await db.select().from(users).where(eq(users.id, userId)).limit(1);
    if (!user) return Response.json({ error: "User not found" }, { status: 404 });
    return Response.json({ user: publicUser(user) });
  }

  if (req.method === "PATCH") {
    const body = await req.json().catch(() => null);
    const updates: Partial<typeof users.$inferInsert> = {};
    if (typeof body?.displayName === "string" && body.displayName.trim()) {
      updates.displayName = body.displayName.trim();
    }
    if (typeof body?.bio === "string") updates.bio = body.bio;
    if (typeof body?.avatarUrl === "string") updates.avatarUrl = body.avatarUrl;

    if (Object.keys(updates).length === 0) {
      return Response.json({ error: "No valid fields to update" }, { status: 422 });
    }

    const [user] = await db.update(users).set(updates).where(eq(users.id, userId)).returning();
    return Response.json({ user: publicUser(user) });
  }

  return new Response("Method not allowed", { status: 405 });
};

export const config: Config = {
  path: "/api/auth/me",
  method: ["GET", "PATCH"],
};
