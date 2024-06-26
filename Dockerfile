FROM node:current-alpine AS build

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm ci

COPY postcss.config.js .
COPY svelte.config.js .
COPY tailwind.config.js .
COPY tsconfig.json .
COPY vite.config.ts .
COPY prisma prisma
COPY static static
COPY src src

RUN npm run build

FROM node:current-alpine AS prod

WORKDIR /app

RUN apk add --no-cache curl

COPY crontab.txt /etc/crontabs/root

COPY package.json package-lock.json ./
COPY prisma prisma

RUN npm ci --production
RUN npm run prisma:gen

COPY --from=build /app/build .

ENTRYPOINT [ "/bin/sh", "-c", "crond && node ." ]
