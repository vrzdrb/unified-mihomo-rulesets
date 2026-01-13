#!/bin/bash

T=$(mktemp) && O="uni-ip4-cidr.yaml" && > "$O"
urls=(
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/community_ips.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/discord_ips.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/ipsum.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/sum/input/ip.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/Discord.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/Meta.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/Twitter.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/cloudflare.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/cloudfront.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/digitalocean.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/discord.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/hetzner.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/meta.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/ovh.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/roblox.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/telegram.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Subnets/IPv4/twitter.lst"
    "https://community.antifilter.download/list/community.lst"
    "https://iplist.opencck.org/?format=clashx&data=cidr4&append=timeout%3D1d%22%20mode=https%20dst-path=cidr4.rsc"
    "https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/main_domains/discord-main-ip-list"
    "https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/voice_domains/discord-voice-ip-list"
    "https://dl.dropboxusercontent.com/s/03w5ojffn6rhpk61rmv26/roblox-ip.yaml?rlkey=axx6ru32c4sg9rcbu65f06s4p&e=1&st=mz0oygfc&dl=0"
)

echo "Загрузка ${#urls[@]} источников..."
for u in "${urls[@]}"; do
    echo -n "$(basename "$u")..." && \
    curl -sSL --connect-timeout 10 --max-time 30 "$u" >> "$T" 2>/dev/null && \
    echo " ✓" || echo " ✗"
done

echo -n "Обработка..." && \
grep -v '^[[:space:]]*[#!]' "$T" | grep -v '^[[:space:]]*$' | \
sed 's/^[[:space:]]*IP-CIDR,[[:space:]]*//i;s/^[[:space:]]*-[[:space:]]*//;s/["'\'']//g' | \
# Разделяем строки с несколькими IP/CIDR (заменяем пробелы на переводы строк)
sed 's/[[:space:]]\+/\n/g' | \
# Убираем лишние пробелы в начале/конце
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
# Фильтруем только строки, которые начинаются с IP-адреса
grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
# Удаляем мусорные символы после CIDR (типа "31138.128.136.0/21" из примера)
sed 's/[^0-9\.\/].*$//' | \
# Добавляем /32 к одиночным IP, проверяем корректность формата
awk '{
    # Убираем все лишние символы кроме цифр, точек и слеша
    gsub(/[^0-9\.\/]/, "", $0)
    if ($0 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/) {
        # Проверяем корректность CIDR
        split($0, parts, "/")
        if (parts[2] >= 0 && parts[2] <= 32) {
            print $0
        }
    } else if ($0 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
        # Одиночный IP - добавляем /32
        print $0 "/32"
    }
}' | sort -u | \
sed "s/^/  - '/;s/$/'/" > "$T.2"

echo " найдено $(wc -l < "$T.2") CIDR" && \
echo "payload:" > "$O" && cat "$T.2" >> "$O"

echo "Первая подсеть: $(head -2 "$O" | tail -1)"
rm -f "$T" "$T.2" && echo "Сохранено в $O"
