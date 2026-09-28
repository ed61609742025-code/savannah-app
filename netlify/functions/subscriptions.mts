import type { Config } from "@netlify/functions";
import { and, eq } from "drizzle-orm";
import { db } from "../../db/index.js";
import { subscriptions } from "../../db/schema.js";
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
    const rows = await db
      .select({ creatorId: subscriptions.creatorId, tier: subscriptions.tier })
      .from(subscriptions)
      .where(eq(subscriptions.userId, userId));
    return Response.json({ subscriptions: rows });
  }

  const body = await req.json().catch(() => null);
  const creatorId = typeof body?.creatorId === "string" ? body.creatorId.trim() : "";
  if (!creatorId) {
    return Response.json({ error: "creatorId is required" }, { status: 422 });
  }

  if (req.method === "POST") {
    const tier = typeof body?.tier === "string" && body.tier.trim() ? body.tier.trim() : "standard";
    await db
      .insert(subscriptions)
      .values({ userId, creatorId, tier })
      .onConflictDoUpdate({ target: [subscriptions.userId, subscriptions.creatorId], set: { tier } });
    return Response.json({ subscribed: true, tier }, { status: 201 });
  }

  if (req.method === "DELETE") {
    await db.delete(subscriptions).where(and(eq(subscriptions.userId, userId), eq(subscriptions.creatorId, creatorId)));
    return Response.json({ subscribed: false });
  }

  return new Response("Method not allowed", { status: 405 });
};

export const config: Config = {
  path: "/api/subscriptions",
  method: ["GET", "POST", "DELETE"],
};
