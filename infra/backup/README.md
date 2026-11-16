# Backups de Postgres → GCS

## Setup en la VM (una sola vez)

```bash
# 1. Subir los archivos
gcloud compute scp infra/backup/pg_backup.sh aliento-andino-vm:/tmp/ --zone=us-central1-a
gcloud compute scp infra/backup/aliento-andino-backup.service aliento-andino-vm:/tmp/ --zone=us-central1-a
gcloud compute scp infra/backup/aliento-andino-backup.timer aliento-andino-vm:/tmp/ --zone=us-central1-a

# 2. Conectar a la VM
gcloud compute ssh aliento-andino-vm --zone=us-central1-a

# Dentro de la VM:
sudo install -m 755 /tmp/pg_backup.sh /usr/local/bin/pg_backup.sh
sudo cp /tmp/aliento-andino-backup.service /etc/systemd/system/
sudo cp /tmp/aliento-andino-backup.timer /etc/systemd/system/

# 3. Configurar variables
sudo mkdir -p /etc/aliento-andino
sudo tee /etc/aliento-andino/backup.env > /dev/null <<EOF
POSTGRES_USER=aliento-andino
POSTGRES_DB=aliento-andino
GCS_BUCKET=aliento-andino-backups
DB_CONTAINER=aliento-andino-db-1
EOF
sudo chmod 600 /etc/aliento-andino/backup.env

# 4. Habilitar el timer
sudo systemctl daemon-reload
sudo systemctl enable --now aliento-andino-backup.timer

# 5. Probar manualmente
sudo systemctl start aliento-andino-backup.service
sudo journalctl -u aliento-andino-backup.service -n 50
```

## Restore desde un backup

```bash
# Listar backups disponibles
gcloud storage ls gs://aliento-andino-backups/

# Descargar uno
gcloud storage cp gs://aliento-andino-backups/aliento-andino-20260524-030000.sql.gz /tmp/

# Restaurar
gunzip -c /tmp/aliento-andino-20260524-030000.sql.gz | \
  docker exec -i aliento-andino-db-1 psql -U aliento-andino -d aliento-andino
```

## Retención

El bucket tiene una **lifecycle rule** que borra automáticamente los objetos con más de 30 días.
