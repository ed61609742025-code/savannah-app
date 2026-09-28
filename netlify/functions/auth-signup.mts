import type { Config } from "@netlify/functions";
import { eq } from "drizzle-orm";
import { db } from "../../db/index.js";
import { users } from "../../db/schema.js";
import { hashPassword, signAuthToken } from "../lib/auth.js";

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
  const body = await req.json().catch(() => null);
  const email = typeof body?.email === "string" ? body.email.trim().toLowerCase() : "";
  const password = typeof body?.password === "string" ? body.password : "";
  const displayName = typeof body?.displayName === "string" ? body.displayName.trim() : "";

  if (!email || !email.includes("@")) {
    return Response.json({ error: "A valid email is required" }, { status: 422 });
  }
  if (password.length < 8) {
    return Response.json({ error: "Password must be at least 8 characters" }, { status: 422 });
  }
  if (!displayName) {
    return Response.json({ error: "Display name is required" }, { status: 422 });
  }

  const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);
  if (existing.length > 0) {
    return Response.json({ error: "An account with this email already exists" }, { status: 409 });
  }

  const passwordHash = await hashPassword(password);
  const [user] = await db
    .insert(users)
    .values({ email, passwordHash, displayName })
    .returning();

  const token = await signAuthToken(user.id);
  return Response.json({ token, user: publicUser(user) }, { status: 201 });
};

export const config: Config = {
  path: "/api/auth/signup",
  method: "POST",
};
