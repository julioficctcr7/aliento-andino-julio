# === Dockerfile para Aliento Andino Mobile (Flutter Web & Test Harness) ===
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS builder

WORKDIR /app

# Copiar manifiesto de dependencias y resolver
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copiar código fuente
COPY . .

# Compilar para Web
RUN flutter build web --release || true

# --- Servir artefactos web compilados con Nginx ---
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
