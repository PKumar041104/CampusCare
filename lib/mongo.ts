import { MongoClient } from 'mongodb';
const uri=process.env.MONGODB_URI||'mongodb://localhost:27017';
const globalForMongo=globalThis as unknown as {mongoClient?:MongoClient};
export const mongoClient=globalForMongo.mongoClient||new MongoClient(uri);
if(process.env.NODE_ENV!=='production') globalForMongo.mongoClient=mongoClient;
export const eventCollection=()=>mongoClient.db(process.env.MONGODB_DATABASE||'smart_campus_events').collection('events');
