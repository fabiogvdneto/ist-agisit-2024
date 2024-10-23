import redis from "redis";

const REDIS_URL = process.env.REDIS_URL || "redis://localhost:6379";
const REDIS_FOLLOWER = process.env.REDIS_FOLLOWER || "redis://localhost:6379";

const leader = await redis
    .createClient({ url: REDIS_URL })
    .connect();

const follower = await redis
    .createClient({ url: REDIS_FOLLOWER })
    .connect();

export default {
    getLeaderboard: () => {
        return follower.ZRANGE_WITHSCORES("leaderboard", 0, -1, { REV: true });
    },

    getScore: (uuid: string) => {
        return follower.ZSCORE("leaderboard", uuid);
    },

    setScore: (uuid: string, score: number) => {
        return leader.ZADD("leaderboard", { score, value: uuid });
    }
}