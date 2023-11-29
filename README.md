### VPS本地IP的acme证书申请一键脚本
-------------------------------------
### 一键脚本
```
bash <(curl -Ls https://gitlab.com/rwkgyg/acme-script/raw/main/acme.sh)
```
---------------------------------------
#### 功能与特点：
1：支持纯IPV4、纯IPV6、双栈VPS

2：支持80端口模式与DNS API模式，支持单域名与泛域名

3：支持Cloudflare/腾讯DNSPod/阿里Aliyun托管解析平台的DNS API申请

4：查询、撤销并删除当前已申请的域名证书 

5：手动一键或者指定续期域名证书

6：两个证书文件的存放路径位于root/ygkkkca文件中

7：已集成于[sing-box-yg脚本](https://github.com/yonggekkk/sing-box-yg)、[x-ui-yg脚本](https://github.com/yonggekkk/x-ui-yg)、[naiveproxy-yg脚本](https://github.com/yonggekkk/NaiveProxy-yg)、[hysteria-yg脚本](https://github.com/yonggekkk/Hysteria-yg)、[tuic-yg脚本](https://github.com/yonggekkk/Tuic-yg)，以上脚本可共享一个证书

#### 注意：使用80端口模式时，会强制释放80端口，且不建议与nginx、caddy类带有自动申请证书的应用同时使用

-------------------------------------------------------------
### 感谢你右上角的star🌟
[![Stargazers over time](https://starchart.cc/yonggekkk/acme-yg.svg)](https://starchart.cc/yonggekkk/acme-yg)
