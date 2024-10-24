import { Hono } from 'hono';
import { write, read } from './redis.ts';
import { onGuessed } from './leaderboard.ts';
import client from 'prom-client'; 

const PORT = Deno.env.get("PORT") || "8000";
const app = new Hono();

// Prometheus metrics
const register = new client.Registry();

const requestCounter = new client.Counter({
  name: 'comparator_total_requests',
  help: 'Total number of requests',
  labelNames: ['route', 'method'],
});

const attemptCounter = new client.Counter({
  name: 'comparator_total_attempts',
  help: 'Total number of attempts made by users',
  labelNames: ['uuid'],
});

const successCounter = new client.Counter({
  name: 'comparator_total_success',
  help: 'Total number of successful guesses',
  labelNames: ['uuid'],
});

// Register the metrics
register.registerMetric(requestCounter);
register.registerMetric(attemptCounter);
register.registerMetric(successCounter);

enum Comparison {
  Less = -1,
  Equal = 0,
  Greater = 1,
}

const compare = (a: number, b: number) => {
  if (a < b) {
    return Comparison.Less;
  } else if (a === b) {
    return Comparison.Equal;
  } else {
    return Comparison.Greater;
  }
}

app.get('/metrics', async (c) => {
  const metrics = await register.metrics();
  return new Response(metrics, {
    headers: { 'Content-Type': 'text/plain' },
    status: 200,
  });
});


app.get('/:uuid', async (c) => {
  const uuid = c.req.param('uuid');
  const attempt = c.req.query('attempt');

  if (!attempt) {
    return c.json({ error: 'Attempt not provided' });
  }

  // Increment request counter for this route and method
  requestCounter.inc({ route: '/:uuid', method: 'GET' });

  const value = await read(`number:${uuid}`);
  if (!value) {
    return c.json({ error: 'UUID not found' });
  }

  let attemptCount = await read('attempt:' + uuid) ?? 0;
  attemptCount++;

  attemptCounter.inc({ uuid });

  const comparison = compare(Number(attempt), Number(value));

  if (comparison === Comparison.Equal) {
    await onGuessed(uuid, attemptCount);
    successCounter.inc({ uuid });
  } else {
    await write('attempt:' + uuid, attemptCount);
  }

  return c.json({ comparison, attemptCount });
});

Deno.serve({port: PORT}, app.fetch);
