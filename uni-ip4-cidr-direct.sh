#!/bin/bash

T=$(mktemp) && O="uni-ip4-cidr-direct.yaml" && > "$O"
urls=(
    "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/cncidr.txt"
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

./mihomo convert-ruleset ipcidr yaml uni-ip4-cidr-direct.yaml uni-ip4-cidr-direct.mrs
