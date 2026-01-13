./uni-adblock.sh
./uni-domains.sh
./uni-domains-direct.sh
./uni-ip4-cidr.sh

./mihomo convert-ruleset domain yaml uni-adblock.yaml uni-adblock.mrs
./mihomo convert-ruleset domain yaml uni-domains.yaml uni-domains.mrs
./mihomo convert-ruleset domain yaml uni-domains-direct.yaml uni-domains-direct.mrs
./mihomo convert-ruleset ipcidr yaml uni-ip4-cidr.yaml uni-ip4-cidr.mrs

echo "Нажмите любую клавишу для выхода"
read -r
