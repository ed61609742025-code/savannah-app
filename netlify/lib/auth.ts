import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from "node:crypto";
import { promisify } from "node:util";
import { SignJWT, jwtVerify } from "jose";

const scrypt = promisify(scryptCallback);
const KEY_LENGTH = 64;
const TOKEN_TTL = "30d";

function getJwtSecret(): Uint8Array {
  const secret = Netlify.env.get("AUTH_JWT_SECRET");
  if (!secret) {
    throw new Error(
      "AUTH_JWT_SECRET is not set. Add it in Project configuration > Environment variables before using auth.",
    );
  }
  return new TextEncoder().encode(secret);
}

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString("hex");
  const derived = (await scrypt(password, salt, KEY_LENGTH)) as Buffer;
  return `${salt}:${derived.toString("hex")}`;
}

export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [salt, hashHex] = stored.split(":");
  if (!salt || !hashHex) return false;
  const derived = (await scrypt(password, salt, KEY_LENGTH)) as Buffer;
  const expected = Buffer.from(hashHex, "hex");
  if (derived.length !== expected.length) return false;
  return timingSafeEqual(derived, expected);
}

export async function signAuthToken(userId: number): Promise<string> {
  return new SignJWT({ sub: String(userId) })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(TOKEN_TTL)
    .sign(getJwtSecret());
}

export async function requireUserId(req: Request): Promise<number> {
  const header = req.headers.get("authorization") ?? "";
  const [scheme, token] = header.split(" ");
  if (scheme !== "Bearer" || !token) {
    throw new AuthRequiredError();
  }
  try {
    const { payload } = await jwtVerify(token, getJwtSecret());
    const userId = Number(payload.sub);
    if (!Number.isInteger(userId)) throw new Error("Invalid subject");
    return userId;
  } catch {
    throw new AuthRequiredError();
  }
}

export class AuthRequiredError extends Error {
  constructor() {
    super("Authentication required");
  }
}
