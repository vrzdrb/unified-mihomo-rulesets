# unified mihomo rulesets
The scripts generate combined mihomo rules &amp; rulesets from 40+ lists from repositories such as:
- [itdoginfo allow-domains](https://github.com/itdoginfo/allow-domains)
- [dartraiden no-russia-hosts](https://github.com/dartraiden/no-russia-hosts)
- [antifilter-community](https://community.antifilter.download)
- [1andrevich Re-filter-lists](https://github.com/1andrevich/Re-filter-lists)
- [iplist.opencck.org](https://iplist.opencck.org)
- [legiz-ru mihomo-rule-sets (apps, games, torrent-clients, discord-vc](https://github.com/legiz-ru/mihomo-rule-sets/tree/main/other)
- [GhostRooter0953 discord-voice-ips] (https://github.com/GhostRooter0953/discord-voice-ips)
- [sjhgvr oisd] (https://github.com/sjhgvr/oisd)

# Usage:
```yaml
sniffer:
  enable: true
  force-dns-mapping: true
  parse-pure-ip: true
  sniff:
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
    TLS:
      ports: [443, 8443]
    QUIC:
      ports: [443, 8443]
      
rule-providers:

  uni-adblock:
    type: http
    behavior: domain
    format: mrs
    url: https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/master/uni-adblock.mrs
    path: ./uni-adblock.mrs
    interval: 86400
  
  uni-app-direct:
    type: http
    behavior: classical
    format: yaml
    url: https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/master/uni-app-direct.yaml
    path: ./uni-app-direct.yaml
    interval: 86400
    
  uni-domains-direct:
    type: http
    behavior: domain
    format: mrs
    url: https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/master/uni-domains-direct.mrs
    path: ./uni-domains-direct.mrs
    interval: 86400

  uni-domains:
    type: http
    behavior: domain
    format: mrs
    url: https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/master/uni-domains.mrs
    path: ./uni-domains.mrs
    interval: 86400

  uni-ip4-cidr:
    type: http
    behavior: ipcidr
    format: mrs
    url: https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/master/uni-ip4-cidr.mrs
    path: ./uni-ip4-cidr.mrs
    interval: 86400

  uni-app-proxy:
    type: http
    behavior: classical
    format: yaml
    url: https://raw.githubusercontent.com/vrzdrb/unified-mihomo-rulesets/master/uni-app-proxy.yaml
    path: ./uni-app-proxy.yaml
    interval: 86400

rules:
  - GEOIP,CN,DIRECT
  - GEOSITE,CN,DIRECT
  - GEOSITE,CATEGORY-RU,DIRECT
  - RULE-SET,uni-app-direct,DIRECT
  - RULE-SET,uni-domains-direct,DIRECT
  - RULE-SET,uni-adblock,REJECT
  - RULE-SET,uni-app-proxy,PROXY
  - RULE-SET,uni-domains,PROXY
  - RULE-SET,uni-ip4-cidr,PROXY        #USE WITH CAUTION (OR JUST DON'T USE')
  - MATCH,DIRECT
```
