# Stage 1: Build Flutter web app
FROM debian:bookworm-slim AS build
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa
RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz \
    && tar xf flutter_linux_3.24.3-stable.tar.xz
ENV PATH="$PATH:/flutter/bin"
RUN flutter config --enable-web
WORKDIR /app
COPY . .
RUN flutter build web

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
