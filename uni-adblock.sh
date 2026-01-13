#!/bin/bash

T=$(mktemp) && U=$(mktemp) && O="uni-adblock.yaml"
> "$O"
urls=(
    "https://raw.githubusercontent.com/sjhgvr/oisd/main/domainswild2_big.txt"
)
echo "Загрузка ${#urls[@]} источников..."
for u in "${urls[@]}"; do
    echo -n "$(basename "$u")..."
    curl -sSL --connect-timeout 10 --max-time 30 "$u" >> "$T" 2>/dev/null && echo " ✓" || echo " ✗"
done

echo -n "Обработка..." && \
sed -i 's/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+[[:space:]]\+//;s/^[[:space:]]*127\.0\.0\.1[[:space:]]\+//;s/^[[:space:]]*0\.0\.0\.0[[:space:]]\+//' "$T" && \
grep -v '#' "$T" | grep -v '^[[:space:]]*!' | grep -v '^[[:space:]]*$' | \
sed 's/^[[:space:]]*DOMAIN-SUFFIX,[[:space:]]*//i;s/^[[:space:]]*DOMAIN,[[:space:]]*//i;s/^[[:space:]]*-[[:space:]]*//;s/["'\'']//g' | \
grep '\.' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' | sort -u > "$U"

echo " найдено $(wc -l < "$U") доменов" && echo "payload:" > "$O" && \
sed "s/^/  - '+./;s/$/'/" "$U" >> "$O"

echo "Первый домен: $(head -2 "$O" | tail -1)"
rm -f "$T" "$U" && echo "Сохранено в $O"
