#!/bin/bash

T=$(mktemp) && U=$(mktemp) && O="uni-domains.yaml"
> "$O"
urls=(
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
    "https://raw.githubusercontent.com/sjhgvr/oisd/refs/heads/main/domainswild2_nsfw_small.txt"
    "https://raw.githubusercontent.com/vrzdrb/clash_roblox_ip_domains/refs/heads/main/roblox-domains.yaml"
    "https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/refs/heads/main/uni-custom-d-proxy.yaml"
    "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/google.txt"
    'https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/gfw.txt'
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

./mihomo convert-ruleset domain yaml uni-domains.yaml uni-domains.mrs
