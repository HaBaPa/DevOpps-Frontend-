# Stage 1: Build Flutter web app
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configure safe Git directory
RUN git config --global --add safe.directory /usr/local/flutter

# Switch Flutter channel and upgrade
RUN flutter channel stable && flutter upgrade

# Check Flutter version
RUN flutter --version

# Set working directory
WORKDIR /app
COPY . .

# Pre-cache for web and enable web support
RUN flutter config --enable-web
RUN flutter pub get

# Build web app
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
