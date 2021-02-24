# ----------------------------------------------------------------------------------------------------------------------
# GLOBAL CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------
# Install Busybox v1.33 on alpine
ARG BUSYBOX_TAG=1.33-musl
# Install Node.js v12.x on alpine
ARG NODE_TAG=erbium-alpine3.11

# Default to production, compose overrides this to development on build and run
ARG NODE_ENV=production
ARG HOST=0.0.0.0
ARG PORT=8080

# ----------------------------------------------------------------------------------------------------------------------
# DEVELOP IMAGE
# ----------------------------------------------------------------------------------------------------------------------
FROM node:${NODE_TAG} as develop
MAINTAINER Fulkman <fulkman@pietrum.pl>

ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV
ARG HOST
ENV HOST=$HOST
ARG PORT
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
npm install -g node-gyp; \
#
# Install app dependencies
npm ci; \
#
# Cleanup
npm uninstall -g node-gyp; \
apk del make gcc g++ python; \
rm -rf ~/.cache

CMD npm run develop

# ----------------------------------------------------------------------------------------------------------------------
# BUILDER IMAGE
# ----------------------------------------------------------------------------------------------------------------------
FROM node:${NODE_TAG} as builder
MAINTAINER Fulkman <fulkman@pietrum.pl>

ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY --from=develop /usr/src/app .

RUN set -ex; \
# Test & build project
npm test; \
npm start;

# ----------------------------------------------------------------------------------------------------------------------
# LIGHTEST STATIC SERVER IMAGE (HTTPD)
# ----------------------------------------------------------------------------------------------------------------------
FROM busybox:${BUSYBOX_TAG} as httpd
MAINTAINER Fulkman <fulkman@pietrum.pl>

ARG HOST
ENV HOST=$HOST
ARG PORT
ENV PORT=$PORT
EXPOSE $PORT

# Create server directory
RUN mkdir -p /data
WORKDIR /data
COPY --from=builder /usr/src/app/dist .

CMD busybox httpd -vv -f -p ${HOST}:${PORT}
