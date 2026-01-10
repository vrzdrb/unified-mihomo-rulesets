#!/bin/bash

OUTPUT_YAML="uni-ip4-cidr-direct.yaml"
OUTPUT_TXT="uni-ip4-cidr-direct.txt"
TEMP_FILE=$(mktemp)
CLEANED_CIDRS=$(mktemp)

# Список URL-источников
URLS=(
    "https://raw.githubusercontent.com/AntiZapret/antizapret/refs/heads/master/blacklist4.txt"
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
# 1. Удаляем строки, содержащие # (в любом месте)
grep -v '#' | \
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
