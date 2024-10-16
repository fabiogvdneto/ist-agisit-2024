import redis from "redis";

const url = process.env.REDIS_URL || "redis://localhost:6379";
const client = await redis.createClient({ url })
    .on('error', error => console.error("Redis client error:", error))
    .connect();

function getLeaderboard() {
    return client.ZRANGE_WITHSCORES("leaderboard", 0, -1, { REV: true }) ?? [];
}

function getScore(uuid: string) {
    return client.ZSCORE("leaderboard", uuid);
}

function setScore(uuid: string, score: number) {
    return client.ZADD("leaderboard", { score, value: uuid });
}

export default {
    getLeaderboard,
    getScore,
    setScore
}