#!/bin/bash

# Создаем временные файлы
TEMP_FILE=$(mktemp)
OUTPUT_TXT="uni-domains.txt"
UNIQUE_DOMAINS=$(mktemp)

# Очищаем выходные файлы
> "$OUTPUT_TXT"

# Список URL-источников
URLS=(
    "https://iplist.opencck.org/?format=clashx&data=domains&append=timeout%3D1d%22%20mode=https%20dst-path=domains.rsc"
    "https://raw.githubusercontent.com/dartraiden/no-russia-hosts/refs/heads/master/hosts.txt"
    "https://community.antifilter.download/list/domains.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/anime.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/block.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/geoblock.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/hodca.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/news.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/porn.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/cloudflare.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/cloudfront.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/digitalocean.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/discord.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/google_ai.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/google_play.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/hdrezka.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/hetzner.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/meta.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/ovh.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/telegram.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/tiktok.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/twitter.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/youtube.lst"
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Russia/inside-raw.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/ooni_domains.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/sum/input/domains.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/domains_all.lst"
    "https://raw.githubusercontent.com/1andrevich/Re-filter-lists/refs/heads/main/community.lst"
    "https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/main_domains/discord-main-domains-list"
    "https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/voice_domains/discord-voice-domains-list"
    "https://raw.githubusercontent.com/sjhgvr/oisd/refs/heads/main/domainswild2_nsfw.txt"
    "https://dl.dropboxusercontent.com/s/5cjhhmtthc0va3xo1pfy5/roblox-domains.yaml?rlkey=ab12bw3htswbc8lf1eeb5johu&e=1&st=mmk7azk4&dl=0"
    "https://dl.dropboxusercontent.com/s/tltd3bt9fla2seh80d0ls/uni-custom-d-proxy.yaml?rlkey=u2fl0n9dw2vpd5qe4r610ni8o&e=1&st=ad33j8j4&dl=0"
)

echo "Начинаю загрузку доменов из ${#URLS[@]} источников..."

# Обрабатываем каждый URL
for url in "${URLS[@]}"; do
    echo "Обрабатываю: $(basename "$url")"
    
    # Скачиваем данные
    curl -sSL --connect-timeout 10 --max-time 30 "$url" >> "$TEMP_FILE" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "  ⚠️  Ошибка при загрузке $url"
    else
        echo "  ✓ Успешно загружено"
    fi
done

echo ""
echo "Очищаю и обрабатываю данные..."

# Обрабатываем hosts-файл формат (0.0.0.0 domain.com)
# Удаляем IP-адреса, оставляя только домены
sed -i 's/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+[[:space:]]\+//' "$TEMP_FILE"
sed -i 's/^[[:space:]]*127\.0\.0\.1[[:space:]]\+//' "$TEMP_FILE"
sed -i 's/^[[:space:]]*0\.0\.0\.0[[:space:]]\+//' "$TEMP_FILE"

# Очищаем данные:
# 1. Удаляем строки, содержащие # в любом месте (комментарии)
# 2. Удаляем строки, начинающиеся с !
# 3. Удаляем пустые строки
# 4. Удаляем строки, содержащие только пробелы
# 5. Удаляем префикс "DOMAIN-SUFFIX," если он уже есть в некоторых источниках
# 6. Удаляем префикс "DOMAIN,"
# 7. Удаляем префикс "  - " если он есть
# 8. Удаляем кавычки
# 9. Оставляем только строки, содержащие точку (чтобы отфильтровать не-домены)
# 10. Удаляем начальные и конечные пробелы
# 11. Конвертируем в нижний регистр для единообразия

grep -v '#' "$TEMP_FILE" | \
grep -v '^[[:space:]]*!' | \
grep -v '^[[:space:]]*$' | \
sed 's/^[[:space:]]*DOMAIN-SUFFIX,[[:space:]]*//i' | \
sed 's/^[[:space:]]*DOMAIN,[[:space:]]*//i' | \
sed 's/^[[:space:]]*-[[:space:]]*//' | \
sed 's/["'\'']//g' | \
grep '\.' | \
sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
tr '[:upper:]' '[:lower:]' | \
sort -u > "$UNIQUE_DOMAINS"

echo "Найдено уникальных доменов: $(wc -l < "$UNIQUE_DOMAINS")"
echo ""

# Преобразуем в нужный формат:   - DOMAIN-SUFFIX,domain.com,PROXY
echo "Форматирую домены в нужный вид..."
# Добавляем отступ и форматирование для каждого домена
sed 's/^/  - DOMAIN-SUFFIX,/' "$UNIQUE_DOMAINS" | sed 's/$/,PROXY/' > "$OUTPUT_TXT"

echo "Сохранено в $OUTPUT_TXT: $(wc -l < "$OUTPUT_TXT") доменов"
echo ""

# Показываем примеры из обоих файлов
echo ""
echo "=== Примеры данных ==="
echo "Первые 5 доменов из $OUTPUT_TXT:"
head -5 "$OUTPUT_TXT"

# Очищаем временные файлы
rm -f "$TEMP_FILE" "$UNIQUE_DOMAINS"

echo ""
echo "Готово! Все домены сохранены в формате Clash в файле $OUTPUT_TXT"
