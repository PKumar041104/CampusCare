// MongoDB stores supplementary append-only workflow events; MySQL remains authoritative.
async function ensureCampusCareCollections(db) {
  await db.collection("events").createIndex({ eventId: 1 }, { unique: true });
  await db.collection("events").createIndex({ requestId: 1, occurredAt: -1 });
  await db.collection("events").createIndex({ actorId: 1, occurredAt: -1 });
  await db.collection("events").createIndex({ eventType: 1, occurredAt: -1 });
}

module.exports = { ensureCampusCareCollections };
