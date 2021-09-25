
echo '============= start build.sh ==================='
echo '============= change config ==================='
rm ./_config.yml
cp ./blog_config/_config_github.yml ./_config.yml
ls -la 
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
# hexo clean --debug
echo '-------------------------------'
# 生成静态网页
hexo generate --debug
ls -la
echo '-------------------------------'
rm -rf ./docs
cp -rf ./docs_github  ./docs
cp ./blog_config/_config_github.yml ./docs/_config_github.yml
ls -la
echo '============= end build.sh ==================='






