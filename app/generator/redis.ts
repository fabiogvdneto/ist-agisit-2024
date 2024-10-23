import { createClient } from "npm:redis@^4.5";

const REDIS_URL = Deno.env.get("REDIS_URL") || "redis://localhost:6379";
const REDIS_FOLLOWER = Deno.env.get("REDIS_FOLLOWER") || "redis://localhost:6379";

// make a connection to the local instance of redis
const leader = createClient({
    url: REDIS_URL,
});

const follower = createClient({
    url: REDIS_FOLLOWER,
});

await leader.connect();
await follower.connect();

export const write = async (key: string, value: string|number) => {
    return leader.set(key, value);
}

export const read = async (key: string) => {
    return follower.get(key);
}

export const del = async (key: string) => {
    return leader.del(key);
}