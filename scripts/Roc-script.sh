#!/bin/bash
# =========================================
# OpenWrt 自定义构建脚本
# 功能：修改默认配置 + 移除冲突包 + 拉取第三方插件
# 作者：Kris
# =========================================

# -------- 修改默认配置 --------
# 默认 IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# 默认主机名
sed -i "s/hostname='.*'/hostname='Roc'/g" package/base-files/files/bin/config_generate
# LuCI 状态页编译署名
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ Built by Roc')/g" \
  feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# -------- 移除冲突/旧版本包 --------
rm -rf feeds/luci/applications/luci-app-wechatpush
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/net/ariang
rm -rf feeds/packages/net/frp
rm -rf feeds/packages/lang/golang

# -------- Git 稀疏克隆函数 --------
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# -------- 基础插件 --------
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2 package/openlist
git_sparse_clone ariang https://github.com/laipeng668/packages net/ariang
git_sparse_clone frp https://github.com/laipeng668/packages net/frp
mv -f package/frp feeds/packages/net/frp
git_sparse_clone frp https://github.com/laipeng668/luci applications/luci-app-frpc applications/luci-app-frps
mv -f package/luci-app-frpc feeds/luci/applications/luci-app-frpc
mv -f package/luci-app-frps feeds/luci/applications/luci-app-frps
git_sparse_clone master https://github.com/kenzok8/openwrt-packages adguardhome luci-app-adguardhome
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/luci-app-lucky
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush package/luci-app-wechatpush
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led \
         package/luci-app-athena-led/root/usr/sbin/athena-led

# -------- 网络代理相关 --------
git clone --depth=1 -b main https://github.com/VIKINGYFY/homeproxy package/homeproxy
git clone --depth=1 -b main https://github.com/nikkinikki-org/OpenWrt-momo package/momo
git clone --depth=1 -b main https://github.com/nikkinikki-org/OpenWrt-nikki package/nikki

git_sparse_clone dev https://github.com/vernesong/OpenClash pkg
mv -f package/pkg package/openclash

git_sparse_clone main https://github.com/xiaorouji/openwrt-passwall pkg
mv -f package/pkg package/passwall

git_sparse_clone main https://github.com/xiaorouji/openwrt-passwall2 pkg
mv -f package/pkg package/passwall2

# -------- feeds 更新 --------
./scripts/feeds update -a
./scripts/feeds install -a

echo "✅ 自定义环境准备完成，可以开始 make menuconfig 了！"
