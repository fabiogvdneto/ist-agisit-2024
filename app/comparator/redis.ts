import { createClient } from "npm:redis@^4.5";

const REDIS_URL = Deno.env.get("REDIS_URL") || "redis://localhost:6379";

// make a connection to the local instance of redis
const client = createClient({
    url: REDIS_URL,
});

await client.connect();

export const write = async (key: string, value: string|number) => {
    return client.set(key, value);
}

export const read = async (key: string) => {
    return client.get(key);
}