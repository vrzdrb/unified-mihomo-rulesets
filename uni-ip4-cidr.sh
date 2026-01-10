#!/bin/bash

OUTPUT_YAML="uni-ip4-cidr.yaml"
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

# Очищаем выходные файлы
> "$OUTPUT_YAML"
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

# Создаем YAML файл с форматом Clash
echo "Формирую итоговый файл $OUTPUT_YAML..."
echo "payload:" > "$OUTPUT_YAML"

# Форматируем для Clash и добавляем в YAML файл
while read -r cidr; do
    # Пропускаем пустые строки
    if [[ -n "$cidr" ]]; then
        echo "  - IP-CIDR,$cidr" >> "$OUTPUT_YAML"
    fi
done < "$CLEANED_CIDRS"

echo "Готово!"
echo "Создан файл: $OUTPUT_YAML"
echo "Добавлено CIDR в YAML: $(grep -c "IP-CIDR" "$OUTPUT_YAML")"

# Показываем примеры
echo -e "\n=== Примеры данных ==="
echo "Первые 5 CIDR из $OUTPUT_TXT:"
head -5 "$OUTPUT_TXT"
echo ""
echo "Первые 5 записей из $OUTPUT_YAML:"
head -6 "$OUTPUT_YAML"  # 6 строк, чтобы захватить "payload:" и 5 CIDR

# Очистка временных файлов
rm -f "$TEMP_FILE" "$CLEANED_CIDRS"
