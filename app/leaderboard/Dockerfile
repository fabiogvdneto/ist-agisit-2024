# dockerfile provided by:
# https://bun.sh/guides/ecosystem/docker

FROM oven/bun:1 AS base
WORKDIR /usr/src/app

FROM base AS install
COPY package.json bun.lockb /temp/
RUN cd /temp/ && bun install --frozen-lockfile --production

FROM base AS release
COPY --from=install /temp/node_modules node_modules
COPY index.ts redis.ts package.json ./

# run the app
USER bun
EXPOSE 80/tcp
ENTRYPOINT [ "bun", "run", "index.ts" ]