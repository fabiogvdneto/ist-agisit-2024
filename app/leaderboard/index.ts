import redis from './redis.ts';
import client from 'prom-client'; // Import prom-client for Prometheus metrics

const PORT = Bun.env.PORT || "8000";

// Prometheus metrics
const register = new client.Registry();

const requestCounter = new client.Counter({
    name: 'leaderboard_request_count',
    help: 'Number of requests made to the leaderboard service',
    labelNames: ['uuid'], 
});

const postScoreCounter = new client.Counter({
    name: 'leaderboard_post_score_count',
    help: 'Number of POST requests to update a user score',
});

const requestDurationHistogram = new client.Histogram({
    name: 'leaderboard_request_duration_seconds',
    help: 'Duration of leaderboard requests in seconds',
    buckets: [0.1, 0.5, 1, 2, 5], // Time buckets in seconds
});

register.registerMetric(requestCounter);
register.registerMetric(postScoreCounter);
register.registerMetric(requestDurationHistogram);


Bun.serve({
    port: PORT,
    async fetch(req) {
        const url = new URL(req.url);

        if (url.pathname === '/metrics') {
            const metrics = await register.metrics(); // Get metrics
            return new Response(metrics, {
                headers: { 'Content-Type': register.contentType },
                status: 200,
            });
        }

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

            // Measure the duration of the POST request
            const end = requestDurationHistogram.startTimer(); 
            const response = await post(parseInt(score), uuid);
            end(); 

            requestCounter.inc({ uuid }); 
            return response;
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
        postScoreCounter.inc(); 
        return new Response('Created', { status: 201 });
    }

    return new Response('Success', { status: 200 });
}