FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
COPY public ./public
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:stable-alpine

# Clean default html
RUN rm -rf /usr/share/nginx/html/*

# Provide main config (sets pid to /var/cache/nginx/nginx.pid)
COPY nginx-main.conf /etc/nginx/nginx.conf

# Provide server config (listens on 8080)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ensure writable dirs for non-root (cache, html, logs dir path)
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/log/nginx \
    && chown -R 101:0 /var/cache/nginx /usr/share/nginx/html /var/log/nginx \
    && chmod -R g+rwX /var/cache/nginx /usr/share/nginx/html /var/log/nginx

# Static files
COPY --from=builder /app/dist /usr/share/nginx/html

USER 101
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
