# Install Node.js v10.x
FROM node:dubnium-alpine
MAINTAINER Fulkman

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

CMD [ "npm", "run", "develop" ]
