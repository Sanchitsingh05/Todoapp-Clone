FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json tsconfig.json vite.config.ts ./
COPY public ./public
COPY tailwind.config.js postcss.config.js ./

RUN npm ci

RUN npm run build

FROM nginx:stable-alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
