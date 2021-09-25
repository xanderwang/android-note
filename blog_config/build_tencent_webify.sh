
echo '============= start build.sh ==================='
ls -la 
echo '============= change config ==================='
rm ./_config.yml
cp ./blog_config/_config_tencent_webify.yml ./_config.yml
rm ./_config.volantis.yml
cp ./blog_config/_config.volantis_tencent_webify.yml ./_config.volantis.yml
cat ./_config.yml
echo '------------------------------- start npm install '
# 安装依赖的环境
# npm install
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
npm install hexo-wordcount
npm install hexo-generator-search 
npm install hexo-generator-json-content
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
# 生成静态网页
hexo generate --debug
ls -la
rm -rf ./docs
cp -rf ./docs_tencent_webify  ./docs
cp ./blog_config/_config_tencent_webify.yml ./docs/_config_tencent_webify.yml
ls -la
echo '============= end build.sh ==================='






