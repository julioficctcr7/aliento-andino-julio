#!/bin/bash
# Backup diario de Postgres a Object Storage (GCS / S3 / R2).
# Diseñado para correr en el host via systemd timer o cron.
#
# Requisitos:
# - CLI configurada para object storage
# - postgres corriendo en contenedor docker (compose service "db")
# - Variables en /etc/aliento-andino/backup.env: POSTGRES_USER, POSTGRES_DB, BUCKET_NAME

set -euo pipefail

CONFIG_FILE="${BACKUP_CONFIG:-/etc/aliento-andino/backup.env}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

POSTGRES_USER="${POSTGRES_USER:-aliento_andino}"
POSTGRES_DB="${POSTGRES_DB:-aliento_andino}"
BUCKET_NAME="${BUCKET_NAME:-aliento-andino-backups}"
DB_CONTAINER="${DB_CONTAINER:-aliento-andino-db-1}"

TIMESTAMP=$(date -u +%Y%m%d-%H%M%S)
DUMP_FILE="/tmp/aliento-andino-${TIMESTAMP}.sql.gz"

echo "[backup] $(date -u +%FT%TZ) Iniciando dump de $POSTGRES_DB"

docker exec "$DB_CONTAINER" pg_dump \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  --no-owner --no-privileges --clean --if-exists \
  | gzip -9 > "$DUMP_FILE"

SIZE=$(du -h "$DUMP_FILE" | cut -f1)
echo "[backup] Dump completado ($SIZE)"

if command -v gsutil &>/dev/null; then
  gsutil cp "$DUMP_FILE" "gs://$BUCKET_NAME/$(basename "$DUMP_FILE")"
  echo "[backup] Subido a gs://$BUCKET_NAME/$(basename "$DUMP_FILE")"
elif command -v aws &>/dev/null; then
  aws s3 cp "$DUMP_FILE" "s3://$BUCKET_NAME/$(basename "$DUMP_FILE")"
  echo "[backup] Subido a s3://$BUCKET_NAME/$(basename "$DUMP_FILE")"
else
  echo "[backup] Archivo guardado localmente en $DUMP_FILE (no se encontró cliente de storage remoto)"
fi

rm -f "$DUMP_FILE"
echo "[backup] OK"
