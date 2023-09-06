FROM public.ecr.aws/docker/library/node:16.16.0-slim as builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build