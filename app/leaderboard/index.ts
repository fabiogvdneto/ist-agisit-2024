import redis from './redis.js';

const PORT = Bun.env.PORT || "8000";

Bun.serve({
    port: PORT,
    async fetch(req) {
        const url = new URL(req.url);

        if (url.pathname !== '/') {
            return new Response('Not Found', { status: 404 })
        }

        if (req.method === 'GET') {
            return get();
        }
        
        if (req.method === 'POST') {
            const score = url.searchParams.get('score');
            if (!score) {
                return new Response('Score paramenter not found');
            }

            const uuid  = url.searchParams.get('uuid');
            if (!uuid) {
                return new Response('UUID paramenter not found');
            }

            return post(parseInt(score), uuid);
        }
        
        return new Response('Method Not Allowed', { status: 405 });
    }
});

async function get() {
    const leaderboard = await redis.getLeaderboard() ?? [];
    return Response.json(leaderboard, { status: 200 });
}

async function post(score: number, uuid: string) {
    const curr: number = await redis.getScore(uuid) ?? 0;

    if (curr < score) {
        await redis.setScore(uuid, score);
        return new Response('Created', { status: 201 });
    }

    return new Response('Success', { status: 200 });
}