import { Hono } from 'hono';
import { write, read } from './redis.ts';
import { onGuessed } from "./leaderboard.ts";

const app = new Hono();

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

// This should only be used for debugging!!!
app.get('/:uuid', async (c) => {
  const uuid = c.req.param('uuid');
  const attempt = c.req.query('attempt');

  if (!attempt) {
    return c.json({ error: 'Attempt not provided' });
  }

  const value = await read(`number:${uuid}`);
  if (!value) {
    return c.json({ error: 'UUID not found' });
  }

  let attemptCount = await read('attempt:' + uuid) ?? 0;
  attemptCount++;

  const comparison = compare(Number(attempt), Number(value));
  if (comparison === Comparison.Equal) await onGuessed(uuid, attemptCount);
  else await write('attempt:' + uuid, attemptCount);

  return c.json({ comparison, attemptCount });
});

Deno.serve(app.fetch);
