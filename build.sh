
echo '============= start build.sh ==================='
ls -la 
echo '------------------------------- start npm install '
# 安装依赖的环境
# npm install
# sudo npm install hexo -g
sudo npm install hexo-cli -g
npm install hexo-generator-archive
npm install hexo-generator-category
npm install hexo-generator-index
npm install hexo-generator-tag
npm install hexo-renderer-ejs
npm install hexo-renderer-marked
npm install hexo-renderer-stylus
npm install hexo-server
npm install hexo-theme-landscape
npm install hexo-theme-volantis
npm install hexo-helper-qrcode
echo '------------------------------- end npm install '
# cd node_modules
# ls -la
# cd ../
# echo '-------------------------------'
hexo version
echo '-------------------------------'
# 删除之前编译的
# rm -rf ./doc
hexo clean --debug
echo '-------------------------------'
# 编译
hexo generate --debug
# 拷贝内容
# cp -R ./public/* ./
ls -la
echo '============= end build.sh ==================='






