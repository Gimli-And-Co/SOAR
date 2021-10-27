
FROM node:14-alpine as BUILD_IMAGE

WORKDIR /build

COPY . .

COPY ./.env.prod ./.env
RUN yarn install --frozen-lockfile

RUN yarn build

FROM node:14-alpine

WORKDIR /home/node/app

COPY ./.env.prod ./.env
COPY --from=BUILD_IMAGE /build/package.json ./
COPY --from=BUILD_IMAGE /build/dist ./dist
COPY --from=BUILD_IMAGE /build/node_modules ./node_modules

ENV PORT 80
EXPOSE 80
CMD ["node", "/home/node/app/dist/main"]