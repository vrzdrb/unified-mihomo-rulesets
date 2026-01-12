#!/bin/bash

# Создаем временные файлы
TEMP_FILE=$(mktemp)
OUTPUT_TXT="uni-adblock.txt"
UNIQUE_DOMAINS=$(mktemp)

# Очищаем выходные файлы
> "$OUTPUT_TXT"


# Список URL-источников
URLS=(
    "https://raw.githubusercontent.com/sjhgvr/oisd/main/domainswild2_big.txt"
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

# Преобразуем в нужный формат:   - DOMAIN-SUFFIX,domain.com,REJECT
echo "Форматирую домены в нужный вид..."
# Добавляем отступ и форматирование для каждого домена
sed 's/^/  - DOMAIN-SUFFIX,/' "$UNIQUE_DOMAINS" | sed 's/$/,REJECT/' > "$OUTPUT_TXT"

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
echo "Готово! Все домены сохранены в формате Clash (REJECT) в файле $OUTPUT_TXT"
