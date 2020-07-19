# Install Node.js v10.x on alpine
ARG NODE_TAG=dubnium-alpine3.11
FROM node:${NODE_TAG}
MAINTAINER Fulkman <fulkman@pietrum.pl>

# Default to production, compose overrides this to development on build and run
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV
ARG HOST=0.0.0.0
ENV HOST=$HOST
ARG PORT_TARGET=3000
ENV PORT=$PORT_TARGET
ARG PORT_PUBLISHED=$PORT_TARGET
ENV PORT_PUBLISHED=$PORT_PUBLISHED
EXPOSE $PORT

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . .

RUN set -ex; \
# Update/Upgrade OS
apk update; \
#
# For native dependencies, you'll need extra tools
apk add --no-cache make gcc g++ python; \
#
# For compile npm module
npm install -g node-gyp; \
#
# Install app dependencies
npm ci; \
#
# Cleanup
npm uninstall -g node-gyp; \
apk del make gcc g++ python; \
rm -rf ~/.cache

CMD [ "npm", "start" ]
