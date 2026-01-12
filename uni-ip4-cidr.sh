#!/bin/bash

OUTPUT_TXT="uni-ip4-cidr.txt"
TEMP_FILE=$(mktemp)
CLEANED_CIDRS=$(mktemp)

# Список URL-источников
URLS=(
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

echo "Начинаю загрузку IP-диапазонов из ${#URLS[@]} источников..."

# Загружаем все данные во временный файл
for url in "${URLS[@]}"; do
    echo "Загружаю: $(basename "$url")"
    curl -sSL --connect-timeout 10 --max-time 30 "$url" 2>/dev/null
    echo ""
done > "$TEMP_FILE"

echo "Загружено. Начинаю обработку..."
echo "Исходных строк: $(wc -l < "$TEMP_FILE")"

> "$OUTPUT_TXT"

# Обрабатываем данные и сохраняем в очищенный файл
cat "$TEMP_FILE" | \
# 1. Удаляем комментарии
grep -v '^[[:space:]]*[#!]' | \
# 2. Удаляем пустые строки
grep -v '^[[:space:]]*$' | \
# 3. Удаляем префикс IP-CIDR, если есть
sed 's/^[[:space:]]*IP-CIDR,[[:space:]]*//i' | \
# 4. Удаляем префикс "  - " если есть (формат Clash)
sed 's/^[[:space:]]*-[[:space:]]*//' | \
# 5. Удаляем кавычки и лишние пробелы
sed 's/["'\'']//g' | \
sed 's/[[:space:]]*$//' | \
sed 's/^[[:space:]]*//' | \
# 6. Фильтруем только строки, похожие на IP/CIDR
grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
# 7. Конвертируем одиночные IP в CIDR (/32)
awk '{
    if ($0 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+$/) {
        # Уже CIDR - оставляем как есть
        print $0
    } else if ($0 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
        # Одиночный IP - добавляем /32
        print $0 "/32"
    }
}' | \
# 8. Сортируем и удаляем дубликаты
sort -u -V > "$CLEANED_CIDRS"

echo "Очищено уникальных CIDR: $(wc -l < "$CLEANED_CIDRS")"
echo ""

# Сохраняем очищенные CIDR в текстовый файл
echo "Сохраняю очищенные CIDR в $OUTPUT_TXT..."
cp "$CLEANED_CIDRS" "$OUTPUT_TXT"
echo "Сохранено в $OUTPUT_TXT: $(wc -l < "$OUTPUT_TXT") CIDR"
echo ""

# Показываем примеры
echo -e "\n=== Примеры данных ==="
echo "Первые 5 CIDR из $OUTPUT_TXT:"
head -5 "$OUTPUT_TXT"

# Очистка временных файлов
rm -f "$TEMP_FILE" "$CLEANED_CIDRS"
