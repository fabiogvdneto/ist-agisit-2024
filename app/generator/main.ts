import { Hono } from 'hono';
import { write, read } from './redis.ts';
import client from 'prom-client'; 

const PORT = Deno.env.get("PORT") || "8000";
const app = new Hono();

// Prometheus metrics 
const register = new client.Registry();

const requestCounter = new client.Counter({
  name: 'generator_total_requests',
  help: 'Total number of requests',
  labelNames: ['route', 'method'],
});

const generatedNumberCounter = new client.Counter({
  name: 'generator_total_numbers_generated',
  help: 'Total number of random numbers generated',
});

// Register the metrics
register.registerMetric(requestCounter);
register.registerMetric(generatedNumberCounter);


app.get('/metrics', async (c) => {
  const metrics = await register.metrics();
  return new Response(metrics, {
    headers: { 'Content-Type': 'text/plain' },
    status: 200,
  });
});


app.get('/', async (c) => {
  requestCounter.inc({ route: '/', method: 'GET' });

  const uuid = crypto.randomUUID();
  const random = Math.floor(Math.random() * 100) + 1;

  generatedNumberCounter.inc();

  await write(`number:${uuid}`, random);

  return c.json({ uuid });
});

// This should only be used for debugging!!!
app.get('/:uuid', async (c) => {
  requestCounter.inc({ route: '/:uuid', method: 'GET' });

  const uuid = c.req.param('uuid');
  const value = await read(`number:${uuid}`);

  return c.json({ value });
});

Deno.serve({ port: PORT }, app.fetch);
