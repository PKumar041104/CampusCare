import { randomUUID } from "crypto";
import { MongoClient } from "mongodb";

const uri = process.env.MONGODB_URI || "mongodb://127.0.0.1:27017";
const database = process.env.MONGODB_DATABASE || "smart_campus_events";
const globalForMongo = globalThis as typeof globalThis & { campusCareMongo?: MongoClient };

export const mongoClient =
  globalForMongo.campusCareMongo ||
  new MongoClient(uri, { serverSelectionTimeoutMS: 2500, maxPoolSize: 5 });

if (process.env.NODE_ENV !== "production") globalForMongo.campusCareMongo = mongoClient;

export async function initializeMongo(): Promise<void> {
  if (process.env.MONGODB_ENABLED === "false") return;
  await mongoClient.connect();
  const events = mongoClient.db(database).collection("events");
  await events.createIndex({ eventId: 1 }, { unique: true });
  await events.createIndex({ requestId: 1, occurredAt: -1 });
  await events.createIndex({ actorId: 1, occurredAt: -1 });
  await events.createIndex({ eventType: 1, occurredAt: -1 });
}

// MySQL commits are authoritative; a temporary MongoDB outage never loses a request workflow.
export async function recordEvent(event: Record<string, unknown>): Promise<void> {
  if (process.env.MONGODB_ENABLED === "false") return;
  try {
    await mongoClient.connect();
    await mongoClient.db(database).collection("events").insertOne({
      eventId: randomUUID(),
      occurredAt: new Date(),
      ...event,
    });
  } catch (error) {
    console.warn("CampusCare event mirror unavailable:", error instanceof Error ? error.message : "unknown error");
  }
}
