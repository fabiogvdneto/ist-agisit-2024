import { del } from "./redis.ts";

const LEADERBOARD_URL = Deno.env.get("LEADERBOARD_URL") || "http://localhost:8002";

export const onGuessed = async (uuid: string, attemptCount: number) => {
    await fetch(`${LEADERBOARD_URL}?uuid=${uuid}&score=${attemptCount}`, {
        method: 'POST',
    })
  
    // "Garbage collect"
    await del(`number:${uuid}`)
    await del('attempt:' + uuid)
  }