### VPS本地IP的acme证书申请一键脚本
-------------------------------------
### 一键脚本
```
bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh)
```
或者
```
bash <(wget -qO- https://raw.githubusercontent.com/yonggekkk/acme-yg/main/acme.sh)
```
---------------------------------------

脚本的视频教程：https://youtu.be/dp0jUG17sZU

---------------------------------------

#### 功能与特点：
1：支持纯IPV4、纯IPV6、双栈VPS

2：支持IP、域名、DNS API三种方式申请证书，支持单域名与泛域名

3：80端口模式支持【没有域名也能申请域名证书】，利用nip.io后缀域名解析IP申请域名证书

4：支持Cloudflare/腾讯DNSPod/阿里Aliyun托管解析平台的DNS API申请

5：查询、撤销并删除当前已申请的域名证书 

6：手动一键或者指定续期域名证书

7：域名证书与 IP 证书可同时维护，分别存放在 `/root/ygkkkca/domain` 与 `/root/ygkkkca/ip`

为兼容现有代理脚本，`/root/ygkkkca/cert.crt`、`private.key` 和 `ca.log` 会保留为软链接；域名证书存在时优先指向域名证书，否则指向 IP 证书。再次申请另一类证书不会卸载 acme.sh，也不会覆盖已有证书记录。

8：已集成以下代理脚本中（可共享一个证书）：

[argosbx脚本](https://github.com/yonggekkk/argosbx)

[sing-box-yg脚本](https://github.com/yonggekkk/sing-box-yg)

[x-ui-yg脚本](https://github.com/yonggekkk/x-ui-yg)

[naiveproxy-yg脚本](https://github.com/yonggekkk/NaiveProxy-yg)

[hysteria-yg脚本](https://github.com/yonggekkk/Hysteria-yg)(已停更，合并到sing-box-yg脚本)

[tuic-yg脚本](https://github.com/yonggekkk/Tuic-yg)(已停更，合并到sing-box-yg脚本)

#### 注意：使用80端口模式时，会强制释放80端口，且不建议与nginx、caddy类带有自动申请证书的应用同时使用

---------------------------------------------

#### 脚本预览图如下：

![47d4c68b8200aff3d4c94288f9adf81](https://github.com/yonggekkk/acme-yg/assets/121604513/deb30cc7-5469-40b5-b747-0b1f481ec825)

---------------------------------------
#### 声明：所有代码来源于Github社区与ChatGPT的整合
