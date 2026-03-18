#!/bin/bash

T=$(mktemp) && U=$(mktemp) && O="uni-domains-direct.yaml"
> "$O"
urls=(
    "https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Russia/outside-raw.lst"
    "https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/refs/heads/main/uni-custom-d-direct.yaml"
    "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/private.txt"
    "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/direct.txt"
    "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/apple.txt"
    "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/icloud.txt"
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

./mihomo convert-ruleset domain yaml uni-domains-direct.yaml uni-domains-direct.mrs
