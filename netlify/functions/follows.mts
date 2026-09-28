import type { Config } from "@netlify/functions";
import { and, eq } from "drizzle-orm";
import { db } from "../../db/index.js";
import { follows } from "../../db/schema.js";
import { AuthRequiredError, requireUserId } from "../lib/auth.js";

export default async (req: Request) => {
  let userId: number;
  try {
    userId = await requireUserId(req);
  } catch (e) {
    if (e instanceof AuthRequiredError) return Response.json({ error: e.message }, { status: 401 });
    throw e;
  }

  if (req.method === "GET") {
    const rows = await db.select({ creatorId: follows.creatorId }).from(follows).where(eq(follows.userId, userId));
    return Response.json({ creatorIds: rows.map((r) => r.creatorId) });
  }

  const body = await req.json().catch(() => null);
  const creatorId = typeof body?.creatorId === "string" ? body.creatorId.trim() : "";
  if (!creatorId) {
    return Response.json({ error: "creatorId is required" }, { status: 422 });
  }

  if (req.method === "POST") {
    await db.insert(follows).values({ userId, creatorId }).onConflictDoNothing();
    return Response.json({ following: true }, { status: 201 });
  }

  if (req.method === "DELETE") {
    await db.delete(follows).where(and(eq(follows.userId, userId), eq(follows.creatorId, creatorId)));
    return Response.json({ following: false });
  }

  return new Response("Method not allowed", { status: 405 });
};

export const config: Config = {
  path: "/api/follows",
  method: ["GET", "POST", "DELETE"],
};
