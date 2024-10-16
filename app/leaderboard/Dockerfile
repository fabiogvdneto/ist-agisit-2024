# dockerfile provided by:
# https://bun.sh/guides/ecosystem/docker

# use the official Bun image
# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM oven/bun:1 AS base

WORKDIR /usr/src/app
COPY . .

EXPOSE 80

# run the app
USER bun
ENTRYPOINT [ "bun", "run", "index.ts" ]