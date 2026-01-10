./uni-adblock.sh
./uni-domains.sh
./uni-domains-direct.sh
./uni-ip4-cidr.sh
./uni-ip4-cidr-direct.sh

./mihomo convert-ruleset domain text uni-adblock.txt uni-adblock.mrs
./mihomo convert-ruleset domain text uni-domains.txt uni-domains.mrs
./mihomo convert-ruleset domain text uni-domains-direct.txt uni-domains-direct.mrs
./mihomo convert-ruleset ipcidr text uni-ip4-cidr.txt uni-ip4-cidr.mrs
./mihomo convert-ruleset ipcidr text uni-ip4-cidr.txt uni-ip4-cidr-direct.mrs
