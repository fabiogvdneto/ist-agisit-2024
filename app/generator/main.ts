import { Hono } from 'hono';
import { write, read } from './redis.ts';

const app = new Hono();

app.get('/', async (c) => {
  const uuid = crypto.randomUUID();
  const random = Math.floor(Math.random() * 100) + 1;

  await write(uuid, random);

  return c.json({ uuid });
});

// This should only be used for debugging!!!
app.get('/:uuid', async (c) => {
  const uuid = c.req.param('uuid');
  const value = await read(uuid);

  return c.json({ value });
});

Deno.serve(app.fetch);
