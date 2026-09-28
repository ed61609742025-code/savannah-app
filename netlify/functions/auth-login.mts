import type { Config } from "@netlify/functions";
import { eq } from "drizzle-orm";
import { db } from "../../db/index.js";
import { users } from "../../db/schema.js";
import { signAuthToken, verifyPassword } from "../lib/auth.js";

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

  if (!email || !password) {
    return Response.json({ error: "Email and password are required" }, { status: 422 });
  }

  const [user] = await db.select().from(users).where(eq(users.email, email)).limit(1);
  if (!user || !(await verifyPassword(password, user.passwordHash))) {
    return Response.json({ error: "Invalid email or password" }, { status: 401 });
  }

  const token = await signAuthToken(user.id);
  return Response.json({ token, user: publicUser(user) });
};

export const config: Config = {
  path: "/api/auth/login",
  method: "POST",
};
