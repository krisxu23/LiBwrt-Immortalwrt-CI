#!/bin/bash
# =========================================
# OpenWrt 自定义构建脚本
# 功能：
#  - 修改默认配置
#  - 移除冲突包
# 作者：Kris
# =========================================

set -e

# -------- 修改默认配置 --------
echo "🛠️ 修改默认系统配置..."
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='LiBwrt'/g" package/base-files/files/bin/config_generate
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Built by Kris')/g" \
  feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# -------- 移除旧版本冲突包 --------
echo "🧹 清理旧版或冲突包..."
rm -rf feeds/luci/applications/luci-app-wechatpush
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/net/ariang
rm -rf feeds/packages/net/frp
rm -rf feeds/packages/lang/golang

# -------- 添加 small-package 仓库 --------
echo "📦 添加 kenzok8/small-package 源..."
grep -q "src-git smpackage" feeds.conf.default || \
    echo "src-git smpackage https://github.com/kenzok8/small-package" >> feeds.conf.default

# -------- 更新 feeds 并安装 small-package --------
echo "🔄 更新并安装 small-package 插件..."
./scripts/feeds update -a
./scripts/feeds install -a -p smpackage

# -------- 删除 small-package 冲突基础包 --------
echo "⚙️ 删除 small-package 中的冲突基础包..."
rm -rf feeds/smpackage/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb}

# -------- small-package 全部插件已经安装 --------
echo "✅ small-package 插件已安装完成，基础插件和网络代理插件全部来自 small-package"

# -------- feeds 最终更新 --------
echo "🔁 最终 feeds 同步..."
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ 自定义环境准备完成，可以开始 make menuconfig 了！"
