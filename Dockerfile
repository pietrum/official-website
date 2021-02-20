# Install Node.js v12.x on alpine
ARG NODE_TAG=erbium-alpine3.11
FROM node:${NODE_TAG}
MAINTAINER Fulkman <fulkman@pietrum.pl>

# Default to production, compose overrides this to development on build and run
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV
ARG DEST=dist
ENV DEST=$DEST
ARG HOST=0.0.0.0
ENV HOST=$HOST
ARG PORT=8080
ENV PORT=$PORT
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
npm install -g node-gyp http-server; \
#
# Install app dependencies
npm ci; \
#
# Cleanup
npm uninstall -g node-gyp; \
apk del make gcc g++ python; \
rm -rf ~/.cache

CMD npm start && http-server ${DEST} -a ${HOST} -p ${PORT}
