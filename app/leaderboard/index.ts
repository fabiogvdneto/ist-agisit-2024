import redis from 'redis';

const PORT = Bun.env.PORT || "8000";
const REDIS_URL = Bun.env.REDIS_URL || "redis://localhost:6379";

const client =
    await redis.createClient({ url: REDIS_URL })
        .on('error', error => console.error('Redis client error:', error))
        .connect();

const server = Bun.serve({
    port: PORT,
    async fetch(req) {
        const url = new URL(req.url);

        if (url.pathname === "/") {
            if (req.method === "GET") {
                const leaderboard = await client.ZRANGE_WITHSCORES("leaderboard", 0, -1, { REV: true }) ?? [];
                return Response.json(leaderboard, { status: 200 });
            }
            
            if (req.method === "POST") {
                const params = url.searchParams;
                
                const score = params.get("score");
                if (!score) {
                    return new Response("Score paramenter not found");
                }

                const uuid = params.get("uuid");
                if (!uuid) {
                    return new Response("UUID paramenter not found");
                }

                await client.ZADD("leaderboard", { score: parseInt(score), value: uuid });
                return new Response("Success", { status: 201 });
            }
            
            return new Response("Method not allowed", { status: 405 })
        }
            
        return new Response("Page not found", { status: 404 });
    }
});