# unified mihomo rulesets
The scripts generate combined mihomo rules &amp; rulesets from 40+ lists from repositories such as:
- [itdoginfo allow-domains](https://github.com/itdoginfo/allow-domains)
- [dartraiden no-russia-hosts](https://github.com/dartraiden/no-russia-hosts)
- [antifilter-community](https://community.antifilter.download)
- [1andrevich Re-filter-lists](https://github.com/1andrevich/Re-filter-lists)
- [iplist.opencck.org](https://iplist.opencck.org)
- [legiz-ru mihomo-rule-sets (apps, games, torrent-clients](https://github.com/legiz-ru/mihomo-rule-sets/tree/main/other)

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
      
rule-providers:
  
  uni-domains:
    type: http
    behavior: domain
    format: mrs
    url: https://github.com/vrzdrb/unified-mihomo-rulesets/blob/main/uni-domains.mrs
    path: ./unified/uni-domains.mrs
    interval: 86400
  
  uni-ip4-cidr:
    type: http
    behavior: ipcidr
    format: mrs
    url: https://github.com/vrzdrb/unified-mihomo-rulesets/blob/main/uni-ip4-cidr.mrs
    path: ./unified/uni-ip4-cidr.mrs
    interval: 86400
  
  uni-app-proxy:
    type: http
    behavior: classical
    format: yaml
    url: https://github.com/vrzdrb/unified-mihomo-rulesets/blob/main/uni-app-proxy.yaml
    path: ./unified/uni-app-proxy.yaml
    interval: 86400
  
  uni-app-direct:
    type: http
    behavior: classical
    format: yaml
    url: https://github.com/vrzdrb/unified-mihomo-rulesets/blob/main/uni-app-proxy.yaml
    path: ./unified/uni-app-direct.yaml
    interval: 86400

rules:
  - RULE-SET,uni-domains,PROXY
  - RULE-SET,uni-ip4-cidr,PROXY
  - RULE-SET,uni-app-proxy,PROXY
  - RULE-SET,uni-app-direct,DIRECT
  - MATCH,DIRECT
```
