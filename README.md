### VPS本地IP的acme证书申请一键脚本
-------------------------------------
### 一键脚本
```
bash <(curl -Ls https://gitlab.com/rwkgyg/acme-script/raw/main/acme.sh)
```
或者
```
bash <(wget -qO- https://gitlab.com/rwkgyg/acme-script/raw/main/acme.sh 2> /dev/null)
```
---------------------------------------
#### 功能与特点：
1：支持纯IPV4、纯IPV6、双栈VPS

2：支持80端口模式与DNS API模式，支持单域名与泛域名

3：支持Cloudflare/腾讯DNSPod/阿里Aliyun托管解析平台的DNS API申请

4：查询、撤销并删除当前已申请的域名证书 

5：手动一键或者指定续期域名证书

6：两个证书文件存放在root/ygkkkca文件中

7：已集成以下代理脚本中（可共享一个证书）：

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
#### 声明：

#### 该项目使用base64加密，可自行解密，介意者请勿使用，[加密原因在此](https://ygkkk.blogspot.com/2022/06/github.html)

#### 所有代码来源于Github社区与ChatGPT的整合；如您需要开源代码，请提Issues留下您的联系邮箱
